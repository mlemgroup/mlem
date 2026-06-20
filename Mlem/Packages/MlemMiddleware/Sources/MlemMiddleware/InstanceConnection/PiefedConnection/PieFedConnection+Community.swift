//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-07.
//

import Foundation

internal extension PieFedConnection {
    func getCommunity(id: Int) async throws -> Community3Snapshot {
        let request = PieFedGetCommunityRequest(id: id, name: nil)
        let response = try await perform(request)
        return try .init(from: response)
    }
    
    func getCommunity(url: URL) async throws -> Community2Snapshot {
        let request = PieFedResolveObjectRequest(q: url.absoluteString)
        let response = try await perform(request)
        if let community = response.community {
            return try .init(from: community)
        }
        throw ApiClientError.noEntityFound
    }
    
    func searchCommunities(
        query: String,
        pageInfo: PageInfo,
        filter: ListingType = .all,
        sort: CommunitySortType
    ) async throws -> PagedResponse<Community2Snapshot> {
        guard let sort = sort.pieFedSearchSortType else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedSearchRequest(
            q: query,
            type_: .communities,
            sort: sort,
            listingType: filter.pieFedListingType,
            page: try pageInfo.cursor.requirePageNumber,
            limit: pageInfo.limit,
            communityName: nil,
            communityId: nil,
            minimumUpvotes: nil,
            nsfw: nil
        )
        let response = try await perform(request)
        return try .fromPieFed(
            pageInfo: pageInfo,
            items: try response.communities.map { try .init(from: $0) }
        )
    }

    func editCommunityDescription(id: Int, newValue: String?) async throws -> Community2Snapshot {
        let request = PieFedEditCommunityRequest(
            id: id,
            title: nil,
            description: newValue,
            rules: nil,
            iconUrl: nil,
            bannerUrl: nil,
            nsfw: nil,
            restrictedToMods: nil,
            localOnly: nil,
            discussionLanguages: nil,
            communityId: id,
            questionAnswer: nil
        )
        let response = try await perform(request)
        return try .init(from: response.communityView)
    }
    
    @discardableResult
    func getSubscriptionList(pageInfo: PageInfo) async throws -> PagedResponse<Community2Snapshot> {
        let request = PieFedListCommunitiesRequest(
            limit: pageInfo.limit,
            page: try pageInfo.cursor.requirePageNumber,
            showNsfw: true,
            sort: nil,
            type_: .subscribed
        )
        let response = try await perform(request)
        return try .fromPieFed(
            pageInfo: pageInfo,
            items: response.communities.map { try .init(from: $0) }
        )
    }
    
    @discardableResult
    func subscribeToCommunity(id: Int, subscribe: Bool) async throws -> Community2Snapshot {
        let request = PieFedFollowCommunityRequest(communityId: id, follow: subscribe)
        let response = try await perform(request)
        return try .init(from: response.communityView)
    }
    
    @discardableResult
    func blockCommunity(id: Int, block: Bool) async throws -> Community2Snapshot {
        let request = PieFedBlockCommunityRequest(block: block, communityId: id)
        let response = try await perform(request)
        return try .init(from: response.communityView)
    }
    
    @discardableResult
    func removeCommunity(
        id: Int,
        remove: Bool,
        reason: String?
    ) async throws -> Community2Snapshot {
        throw ApiClientError.featureUnsupported
    }
    
    func purgeCommunity(id: Int, reason: String?) async throws {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func addModerator(
        communityId: Int,
        personId: Int,
        added: Bool
    ) async throws -> (moderators: [Person1Snapshot], community: Community1Snapshot) {
        let request = PieFedAddModToCommunityRequest(communityId: communityId, personId: personId, added: added)
        let response = try await perform(request)
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
