//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-07.
//

import Foundation

public extension LemmyConnection {
    func getCommunity(id: Int) async throws -> Community3Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyGetCommunityRequest(endpoint: endpoint, id: id, name: nil)
        }
        return try .init(from: response)
    }
    
    func getCommunity(url: URL) async throws -> Community2Snapshot {
        do {
            let result = try await resolve(url: url)
            switch result {
            case let .community(community):
                return community
            default:
                throw ApiClientError.noEntityFound
            }
        } catch let ApiClientError.response(response, _) where response.couldntFindObject {
            throw ApiClientError.noEntityFound
        }
    }
    
    func getCommunity(url: URL) async throws -> Community3Snapshot {
        let comm: Community2Snapshot = try await getCommunity(url: url)
        return try await getCommunity(id: comm.community.id)
    }
    
    func searchCommunities(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        filter: ListingType = .all,
        sort: SearchSortType = .top(.allTime)
    ) async throws -> [Community2Snapshot] {
        let response = try await performingForEndpoint { endpoint in
            try LemmySearchRequest(
                endpoint: endpoint,
                q: query,
                communityId: nil,
                communityName: nil,
                creatorId: nil,
                type_: .communities,
                sort: sort.apiType(for: endpoint),
                listingType: filter.apiType,
                page: page,
                limit: limit,
                postTitleOnly: false,
                timeRangeSeconds: sort.timeRangeSeconds,
                titleOnly: nil,
                postUrlOnly: nil,
                likedOnly: nil,
                dislikedOnly: nil,
                showNsfw: nil,
                pageCursor: nil,
                pageBack: nil
            )
        }
        return try response.communities?.map { try .init(from: $0) } ?? []
    }

    func editCommunityDescription(id: Int, newValue: String?) async throws -> Community2Snapshot {
         let response = try await performingForEndpoint { endpoint in
            LemmyUpdateCommunityRequest(
                endpoint: endpoint,
                communityId: id,
                title: nil,
                // In the v4 API, the `description` field is for the short description
                description: endpoint == .v3 ? newValue : nil,
                icon: nil,
                banner: nil,
                nsfw: nil,
                postingRestrictedToMods: nil,
                discussionLanguages: nil,
                visibility: nil,
                sidebar: newValue
            )
        }
        return try .init(from: response.communityView)
    }
    
    @discardableResult
    func getSubscriptionList(page: Int, limit: Int) async throws -> [Community2Snapshot] {
        let response = try await performingForEndpoint { endpoint in
            LemmyListCommunitiesRequest(
                endpoint: endpoint,
                type_: .subscribed,
                sort: endpoint == .v4 ? .new(.nameAsc) : .old(.new),
                showNsfw: true,
                page: page,
                limit: limit,
                timeRangeSeconds: nil,
                pageCursor: nil,
                pageBack: nil
            )
        }
        return try response.communities.map { try .init(from: $0) }
    }
    
    @discardableResult
    func subscribeToCommunity(id: Int, subscribe: Bool) async throws -> Community2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyFollowCommunityRequest(endpoint: endpoint, communityId: id, follow: subscribe)
        }
        return try .init(from: response.communityView)
    }
    
    @discardableResult
    func blockCommunity(id: Int, block: Bool) async throws -> Community2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyUserBlockCommunityRequest(endpoint: endpoint, communityId: id, block: block)
        }
        return try .init(from: response.communityView)
    }
    
    @discardableResult
    func removeCommunity(
        id: Int,
        remove: Bool,
        reason: String?
    ) async throws -> Community2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyRemoveCommunityRequest(endpoint: endpoint, communityId: id, removed: remove, reason: reason)
        }
        return try .init(from: response.communityView)
    }
    
    func purgeCommunity(id: Int, reason: String?) async throws {
        _ = try await performingForEndpoint { endpoint in
            LemmyPurgeCommunityRequest(endpoint: endpoint, communityId: id, reason: reason)
        }
    }
    
    @discardableResult
    func addModerator(
        communityId: Int,
        personId: Int,
        added: Bool
    ) async throws -> (moderators: [Person1Snapshot], community: Community1Snapshot) {
        let response = try await performingForEndpoint { endpoint in
            LemmyAddModToCommunityRequest(
                endpoint: endpoint,
                communityId: communityId,
                personId: personId,
                added: added
            )
        }
        let moderators: [Person1Snapshot] = try response.moderators.map { try .init(from: $0.moderator) }
        
        guard let first = response.moderators.first else {
            throw ApiClientError.unsuccessful
        }
        let community: Community1Snapshot = try .init(from: first.community)
        return (
            moderators: moderators,
            community: community
        )
    }
}
