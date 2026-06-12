//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-07.
//

import Foundation

internal extension LemmyConnection {
    func getCommunity(id: Int) async throws -> Community3Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyGetCommunityRequest(endpoint: endpoint, id: id, name: nil)
        }
        return try .init(from: response)
    }
    
    func getCommunity(url: URL) async throws -> Community2Snapshot {
        let result = try await resolve(url: url)
        switch result {
        case let .community(community):
            return community
        default:
            throw ApiClientError.noEntityFound
        }
    }
    
    func searchCommunities(
        query: String,
        pageInfo: PageInfo,
        filter: ListingType = .all,
        sort: CommunitySortType
    ) async throws -> PagedResponse<Community2Snapshot> {
         try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                guard let sortType = sort.v3ApiType else {
                    throw ApiClientError.featureUnsupported
                }
                let request = LemmySearchRequest(
                    endpoint: .v3,
                    q: query,
                    communityId: nil,
                    communityName: nil,
                    creatorId: nil,
                    type_: .communities,
                    sort: sortType,
                    listingType: filter.apiType,
                    page: try pageInfo.cursor.requirePageNumber,
                    limit: pageInfo.limit,
                    postTitleOnly: false,
                    searchTerm: query,
                    creatorUsername: nil,
                    timeRangeSeconds: nil,
                    titleOnly: nil,
                    postUrlOnly: nil,
                    showNsfw: nil,
                    pageCursor: nil
                )
                let response = try await self.perform(request, endpoint: .v3)
                return try .fromLemmyV3(
                    pageInfo: pageInfo,
                    items: response.communities.map { try .init(from: $0) },
                    nextCursor: nil
                )
            case .v4:
                guard let sortType = sort.v4ApiType else {
                    throw ApiClientError.featureUnsupported
                }
                let request = LemmyListCommunitiesRequest(
                    endpoint: .v4,
                    type_: filter.apiType,
                    sort: .new(sortType),
                    showNsfw: nil,
                    page: nil,
                    limit: pageInfo.limit,
                    timeRangeSeconds: nil,
                    multiCommunityId: nil,
                    searchTerm: query,
                    searchTitleOnly: nil,
                    pageCursor: try pageInfo.cursor.requireCursorString
                )
                let response = try await self.perform(request, endpoint: .v4)
                return try .init(from: response.toPagedResponse()) {
                    try .init(from: $0)
                }
            }
        }
    }

    func editCommunityDescription(id: Int, newValue: String?) async throws -> Community2Snapshot {
         let response = try await performingForEndpoint { endpoint in
            LemmyEditCommunityRequest(
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
                sidebar: newValue,
                summary: nil
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
                multiCommunityId: nil,
                searchTerm: nil,
                searchTitleOnly: nil,
                pageCursor: nil
            )
        }
        return try response.items.map { try .init(from: $0) }
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
        switch response {
        case let .lemmyBlockCommunityResponse(response):
            return try .init(from: response.communityView)
        case let .lemmyCommunityResponse(response):
            return try .init(from: response.communityView)
        }
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
