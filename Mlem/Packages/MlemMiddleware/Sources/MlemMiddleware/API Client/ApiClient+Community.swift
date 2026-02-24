//
//  NewApiClient+Requests.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation

public extension ApiClient {
    func decodeCommunity(_ data: Community.CodedData) async throws -> Community {
        guard data.apiUrl == baseUrl else {
            throw ApiClientError.mismatchingUrl
        }
        guard try await data.apiMyPersonId == myPersonId else {
            throw ApiClientError.mismatchingPersonId
        }
        return try await caches.community.getModel(
            api: self,
            from: .community1(.init(from: data.apiCommunity)),
            isStale: true
        )
    }
    
    func getCommunity(id: Int) async throws -> Community {
        let snapshot = try await repository.getCommunity(id: id)
        return await caches.community.getModel(api: self, from: .community3(snapshot))
    }
    
    func getCommunity(url: URL) async throws -> Community {
        let snapshot: Community2Snapshot = try await repository.getCommunity(url: url)
        return await caches.community.getModel(api: self, from: .community2(snapshot))
    }
    
    func searchCommunities(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        filter: ListingType = .all,
        sort sort_: SearchSortType? = nil,
        hostApi: ApiClient? = nil
    ) async throws -> [Community] {
        let sort: SearchSortType
        if let sort_ {
            sort = sort_
        } else if try await software.supports(.searchSortType(.top(.allTime))) {
            sort = .top(.allTime)
        } else {
            sort = .top(.limited(.month))
        }
        
        let snapshots = try await repository.searchCommunities(
            query: query,
            page: page,
            limit: limit,
            filter: filter,
            sort: sort
        )
        
        let ret = await caches.community.getModels(api: self, from: snapshots.map { .community2($0) })
        // TODO: NOW
        if let subscriptionInfo = hostApi?.subscriptions {
            for community in ret {
                if let subscribedCommunity = subscriptionInfo.communities.first(where: { $0.actorId == community.actorId }) {
                    community.subscription.addSibling(subscribedCommunity.subscription)
                    // community.subscriptionManager.addSibling(subscribedCommunity.subscriptionManager)
                }
                // TODO: favorites
            }
        }
        
        // if on a foreign host, resolve communities to populate subscription status.
        // TODO: NOW
//        if let hostApi, hostApi !== self {
//            do {
//                let resolvedCommunities: [URL: Community2] = try await hostApi.resolve(urls: ret.map { $0.resolvableUrl(from: .host) })
//                for community in ret {
//                    if let resolvedCommunity = resolvedCommunities[community.resolvableUrl(from: .host)] {
//                        community.blockedManager.addSibling(resolvedCommunity.blockedManager)
//                    }
//                }
//            } catch {
//                // if this fails, don't fail the whole call
//                // TODO: error toast (depends on packaged error handling)
//                log.error("Failed to resolve community URLs: \(error)")
//            }
//        }
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
            let snapshots = try await repository.getSubscriptionList(page: page, limit: limit)
            communities.append(contentsOf: snapshots)
            hasMorePages = snapshots.count >= limit
            page += 1
        } while hasMorePages
            
        let models: Set<Community> = await Set(caches.community.getModels(api: self, from: communities.map { .community2($0) }))
        await subscriptionList.updateCommunities(with: models)
        subscriptionList.hasLoaded = true
        return subscriptionList
    }
    
    func purgeCommunity(id: Int, reason: String?) async throws {
        try await repository.purgeCommunity(id: id, reason: reason)
        caches.community.retrieveModel(cacheId: id)?.purged = true
    }
    
    @discardableResult
    func addModerator(communityId: Int, personId: Int, added: Bool) async throws -> [Person] {
        let snapshots = try await repository.addModerator(
            communityId: communityId,
            personId: personId,
            added: added
        )

        let updatedModerators = await caches.person.getModels(api: self, from: snapshots.moderators.map { .person1($0) })
        
        // TODO: NOW nice way to queue this--move this whole thing into Community?
        if let community = caches.community.retrieveModel(cacheId: communityId) {
            community.moderators.value_ = updatedModerators
        }
        
        if let person = caches.person.retrieveModel(cacheId: personId) {
            let newModerator = snapshots.moderators.first(where: { $0.id == personId })
            if added {
                guard newModerator != nil else { throw ApiClientError.unsuccessful }
                let newModeratedCommunity = await caches.community.getModel(
                    api: self,
                    from: .community1(snapshots.community)
                )
                
                // TODO: NOW nice way to queue this
                if person.moderatedCommunities.value_ == nil {
                    person.moderatedCommunities.value_ = [newModeratedCommunity]
                } else {
                    person.moderatedCommunities.value_?.append(newModeratedCommunity)
                }
            } else {
                guard newModerator == nil else { throw ApiClientError.unsuccessful }
                person.moderatedCommunities.value_?.removeAll(where: { $0.id == communityId })
            }
        }
        
        return updatedModerators
    }
}
