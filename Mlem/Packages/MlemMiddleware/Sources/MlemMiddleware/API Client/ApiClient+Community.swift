//
//  NewApiClient+Requests.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation

public extension ApiClient {
    func decodeCommunity(_ data: Community1.CodedData) async throws -> Community1 {
        guard data.apiUrl == baseUrl else {
            throw ApiClientError.mismatchingUrl
        }
        guard try await data.apiMyPersonId == myPersonId else {
            throw ApiClientError.mismatchingPersonId
        }
        return try await caches.community1.getModel(
            api: self,
            from: .init(from: data.apiCommunity),
            isStale: true
        )
    }
    
    func decodeCommunity(_ data: Community2.CodedData) async throws -> Community2 {
        guard data.apiUrl == baseUrl else {
            throw ApiClientError.mismatchingUrl
        }
        guard try await data.apiMyPersonId == myPersonId else {
            throw ApiClientError.mismatchingPersonId
        }
        return try await caches.community2.getModel(
            api: self,
            from: .init(from: data.apiCommunityView),
            isStale: true
        )
    }
    
    func getCommunity(id: Int) async throws -> Community3 {
        let request = GetCommunityRequest(endpoint: .v3, id: id, name: nil)
        let response = try await perform(request)
        return try await caches.community3.getModel(
            api: self,
            from: .init(from: response)
        )
    }
    
    func getCommunity(url: URL) async throws -> Community2 {
        let request = ResolveObjectRequest(endpoint: .v3, q: url.absoluteString)
        do {
            if let response = try await perform(request).community {
                return try await caches.community2.getModel(
                    api: self,
                    from: .init(from: response)
                )
            }
        } catch let ApiClientError.response(response, _) where response.couldntFindObject {
            throw ApiClientError.noEntityFound
        }
        throw ApiClientError.noEntityFound
    }
    
    func getCommunity(url: URL) async throws -> Community3 {
        let comm: Community2 = try await getCommunity(url: url)
        return try await getCommunity(id: comm.id)
    }
    
    func searchCommunities(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        filter: ApiListingType = .all,
        sort: SearchSortType = .top(.allTime),
        hostApi: ApiClient? = nil
    ) async throws -> [Community2] {
        let endpointVersion = try await version.highestSupportedEndpointVersion
        let request = SearchRequest(
            endpoint: .v3,
            q: query,
            communityId: nil,
            communityName: nil,
            creatorId: nil,
            type_: .communities,
            sort: .init(
                oldSortType: endpointVersion == .v3 ? sort.legacyApiSortType : nil,
                newSortType: endpointVersion == .v4 ? sort.apiSortType : nil
            ),
            listingType: filter,
            page: page,
            limit: limit,
            postTitleOnly: false,
            searchTerm: query,
            timeRangeSeconds: sort.timeRangeSeconds,
            titleOnly: nil,
            postUrlOnly: nil,
            likedOnly: nil,
            dislikedOnly: nil,
            pageCursor: nil,
            pageBack: nil
        )
        
        let response = try await perform(request).communities
        let ret = try await caches.community2.getModels(
            api: self,
            from: (response ?? []).map { try .init(from: $0) }
        )
        if let subscriptionInfo = hostApi?.subscriptions {
            for community in ret {
                if let subscribedCommunity = subscriptionInfo.communities.first(where: { $0.actorId == community.actorId }) {
                    community.subscriptionManager.addSibling(subscribedCommunity.subscriptionManager)
                }
                // TODO: favorites
            }
        }
        if let hostApi {
            let resolvedCommunities: [URL: Community2] = try await hostApi.resolve(urls: ret.map { $0.resolvableUrl(from: .host) })
            for community in ret {
                if let resolvedCommunity = resolvedCommunities[community.resolvableUrl(from: .host)] {
                    community.blockedManager.addSibling(resolvedCommunity.blockedManager)
                }
            }
        }
        return ret
    }
    
    func setupSubscriptionList(
        getFavorites: @escaping () -> Set<Int> = { [] },
        setFavorites: @escaping (Set<Int>) -> Void = { _ in }
    ) -> SubscriptionList {
        if let subscriptions {
            return subscriptions
        } else {
            let new: SubscriptionList = .init(apiClient: self, getFavorites: getFavorites, setFavorites: setFavorites)
            subscriptions = new
            return new
        }
    }
    
    @discardableResult
    func getSubscriptionList() async throws -> SubscriptionList {
        let subscriptionList = setupSubscriptionList()
        
        let limit = 50
        var page = 1
        var hasMorePages = true
        var communities = [ApiCommunityView]()
        
        repeat {
            let request = ListCommunitiesRequest(
                endpoint: .v3,
                type_: .subscribed,
                sort: nil,
                page: page,
                limit: limit,
                showNsfw: true,
                timeRangeSeconds: nil
            )
            let response = try await perform(request)
            communities.append(contentsOf: response.communities)
            hasMorePages = response.communities.count >= limit
            page += 1
        } while hasMorePages
            
        let models: Set<Community2> = try await Set(caches.community2.getModels(
            api: self,
            from: communities.map { try .init(from: $0) }
        ))
        await subscriptionList.updateCommunities(with: models)
        subscriptionList.hasLoaded = true
        return subscriptionList
    }
    
    @discardableResult
    func subscribeToCommunity(id: Int, subscribe: Bool, semaphore: UInt?) async throws -> Community2 {
        let request = FollowCommunityRequest(endpoint: .v3, communityId: id, follow: subscribe)
        let response = try await perform(request)
        return try await caches.community2.getModel(
            api: self,
            from: .init(from: response.communityView),
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func blockCommunity(id: Int, block: Bool, semaphore: UInt? = nil) async throws -> Community2 {
        let request = UserBlockCommunityRequest(endpoint: .v3, communityId: id, block: block)
        let response = try await perform(request)
        let person = try await caches.community2.getModel(
            api: self,
            from: .init(from: response.communityView),
            semaphore: semaphore
        )
        return person
    }
    
    @discardableResult
    func removeCommunity(
        id: Int,
        remove: Bool,
        reason: String?,
        semaphore: UInt? = nil
    ) async throws -> Community2 {
        let request = RemoveCommunityRequest(endpoint: .v3, communityId: id, removed: remove, reason: reason, expires: nil)
        let response = try await perform(request)
        return try await caches.community2.getModel(
            api: self,
            from: .init(from: response.communityView),
            semaphore: semaphore
        )
    }
    
    func purgeCommunity(id: Int, reason: String?) async throws {
        let request = PurgeCommunityRequest(endpoint: .v3, communityId: id, reason: reason)
        let response = try await perform(request)
        guard response.success else { throw ApiClientError.unsuccessful }
        caches.community1.retrieveModel(cacheId: id)?.purged = true
    }
    
    @discardableResult
    func addModerator(communityId: Int, personId: Int, added: Bool) async throws -> [Person1] {
        let request = AddModToCommunityRequest(endpoint: .v3, communityId: communityId, personId: personId, added: added)
        let response = try await perform(request)
        
        let updatedModerators = try await caches.person1.getModels(
            api: self, from: response.moderators.map { try .init(from: $0.moderator) }
        )
        
        if let community = caches.community3.retrieveModel(cacheId: communityId) {
            community.moderators = updatedModerators
        }
        
        if let person = caches.person3.retrieveModel(cacheId: personId) {
            let newModerator = response.moderators.first(where: { $0.moderator.id == personId })
            if added {
                guard let newModerator else { throw ApiClientError.unsuccessful }
                try await person.moderatedCommunities.append(caches.community1.getModel(
                    api: self,
                    from: .init(from: newModerator.community)
                ))
            } else {
                guard newModerator == nil else { throw ApiClientError.unsuccessful }
                person.moderatedCommunities.removeAll(where: { $0.id == communityId })
            }
        }
        
        return updatedModerators
    }
}
