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
        let response = try await performingForConnection { connection in
            try await connection.getCommunity(id: id)
        }
        return await caches.community3.getModel(api: self, from: response)
    }
    
    func getCommunity(url: URL) async throws -> Community2 {
        let response: Community2Snapshot = try await performingForConnection { connection in
            try await connection.getCommunity(url: url)
        }
        return await caches.community2.getModel(api: self, from: response)
    }
    
    func getCommunity(url: URL) async throws -> Community3 {
        let response: Community3Snapshot = try await performingForConnection { connection in
            try await connection.getCommunity(url: url)
        }
        return await caches.community3.getModel(api: self, from: response)
    }
    
    func searchCommunities(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        filter: ListingType = .all,
        sort sort_: SearchSortType? = nil,
        hostApi: ApiClient? = nil
    ) async throws -> [Community2] {
        let sort: SearchSortType
        if let sort_ {
            sort = sort_
        } else if try await software.supports(.searchSortType(.top(.allTime))) {
            sort = .top(.allTime)
        } else {
            sort = .top(.limited(.month))
        }
        
        let response = try await performingForConnection { connection in
            try await connection.searchCommunities(
                query: query,
                page: page,
                limit: limit,
                filter: filter,
                sort: sort
            )
        }
        
        let ret = await caches.community2.getModels(api: self, from: response)
        if let subscriptionInfo = hostApi?.subscriptions {
            for community in ret {
                if let subscribedCommunity = subscriptionInfo.communities.first(where: { $0.actorId == community.actorId }) {
                    community.subscriptionManager.addSibling(subscribedCommunity.subscriptionManager)
                }
                // TODO: favorites
            }
        }
        
        // if on a foreign host, resolve communities to populate subscription status.
        if let hostApi, hostApi !== self {
            do {
                let resolvedCommunities: [URL: Community2] = try await hostApi.resolve(urls: ret.map { $0.resolvableUrl(from: .host) })
                for community in ret {
                    if let resolvedCommunity = resolvedCommunities[community.resolvableUrl(from: .host)] {
                        community.blockedManager.addSibling(resolvedCommunity.blockedManager)
                    }
                }
            } catch {
                // if this fails, don't fail the whole call
                // TODO: error toast (depends on packaged error handling)
                print("Failed to resolve community URLs: \(error)")
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
        var communities = [Community2Snapshot]()
        
        repeat {
            let response = try await performingForConnection { connection in
                try await connection.getSubscriptionList(page: page, limit: limit)
            }
            communities.append(contentsOf: response)
            hasMorePages = response.count >= limit
            page += 1
        } while hasMorePages
            
        let models: Set<Community2> = await Set(caches.community2.getModels(api: self, from: communities))
        await subscriptionList.updateCommunities(with: models)
        subscriptionList.hasLoaded = true
        return subscriptionList
    }
    
    @discardableResult
    func subscribeToCommunity(id: Int, subscribe: Bool, semaphore: UInt?) async throws -> Community2 {
        let response = try await performingForConnection { connection in
            try await connection.subscribeToCommunity(id: id, subscribe: subscribe)
        }
        return await caches.community2.getModel(
            api: self,
            from: response,
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func blockCommunity(id: Int, block: Bool, semaphore: UInt? = nil) async throws -> Community2 {
        let response = try await performingForConnection { connection in
            try await connection.blockCommunity(id: id, block: block)
        }
        return await caches.community2.getModel(
            api: self,
            from: response,
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func removeCommunity(
        id: Int,
        remove: Bool,
        reason: String?,
        semaphore: UInt? = nil
    ) async throws -> Community2 {
        let response = try await performingForConnection { connection in
            try await connection.removeCommunity(
                id: id,
                remove: remove,
                reason: reason
            )
        }
        return await caches.community2.getModel(
            api: self,
            from: response,
            semaphore: semaphore
        )
    }
    
    func purgeCommunity(id: Int, reason: String?) async throws {
        try await performingForConnection { connection in
            try await connection.purgeCommunity(id: id, reason: reason)
        }
        caches.community1.retrieveModel(cacheId: id)?.purged = true
    }
    
    @discardableResult
    func addModerator(communityId: Int, personId: Int, added: Bool) async throws -> [Person1] {
        let response = try await performingForConnection { connection in
            try await connection.addModerator(
                communityId: communityId,
                personId: personId,
                added: added
            )
        }

        let updatedModerators = await caches.person1.getModels(api: self, from: response.moderators)
        
        if let community = caches.community3.retrieveModel(cacheId: communityId) {
            community.moderators = updatedModerators
        }
        
        if let person = caches.person3.retrieveModel(cacheId: personId) {
            let newModerator = response.moderators.first(where: { $0.id == personId })
            if added {
                guard let newModerator else { throw ApiClientError.unsuccessful }
                await person.moderatedCommunities.append(caches.community1.getModel(
                    api: self,
                    from: response.community
                ))
            } else {
                guard newModerator == nil else { throw ApiClientError.unsuccessful }
                person.moderatedCommunities.removeAll(where: { $0.id == communityId })
            }
        }
        
        return updatedModerators
    }
}
