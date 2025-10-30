//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-07.
//

import Foundation

public extension PieFedConnection {
    func getCommunity(id: Int) async throws -> Community3Snapshot {
        let request = PieFedGetCommunityRequest(id: id, name: nil)
        let response = try await perform(request)
        return try .init(from: response)
    }
    
    func getCommunity(url: URL) async throws -> Community2Snapshot {
        do {
            let request = PieFedResolveObjectRequest(q: url.absoluteString)
            let response = try await perform(request)
            if let community = response.community {
                return try .init(from: community)
            }
        } catch let ApiClientError.response(response, _) where response.couldntFindObject {
            throw ApiClientError.noEntityFound
        }
        throw ApiClientError.noEntityFound
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
        guard let sort = sort.pieFedSortType else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedSearchRequest(
            q: query,
            type_: .communities,
            sort: sort,
            listingType: filter.pieFedListingType,
            page: page,
            limit: limit,
            communityName: nil,
            communityId: nil
        )
        let response = try await perform(request)
        return try response.communities.map { try .init(from: $0) }
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
            communityId: id
        )
        let response = try await perform(request)
        return try .init(from: response.communityView)
    }
    
    @discardableResult
    func getSubscriptionList(page: Int, limit: Int) async throws -> [Community2Snapshot] {
        let request = PieFedListCommunitiesRequest(
            type_: .subscribed,
            sort: nil,
            showNsfw: true,
            page: page,
            limit: limit
        )
        let response = try await perform(request)
        return try response.communities.map { try .init(from: $0) }
    }
    
    @discardableResult
    func subscribeToCommunity(id: Int, subscribe: Bool) async throws -> Community2Snapshot {
        let request = PieFedFollowCommunityRequest(communityId: id, follow: subscribe)
        let response = try await perform(request)
        return try .init(from: response.communityView)
    }
    
    @discardableResult
    func blockCommunity(id: Int, block: Bool) async throws -> Community2Snapshot {
        let request = PieFedBlockCommunityRequest(communityId: id, block: block)
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
