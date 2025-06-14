//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-07.
//

import Foundation

public extension PieFedConnection {
    func getCommunity(id: Int) async throws -> Community3Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getCommunity(url: URL) async throws -> Community2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getCommunity(url: URL) async throws -> Community3Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func searchCommunities(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        filter: ListingType = .all,
        sort: SearchSortType = .top(.allTime)
    ) async throws -> [Community2Snapshot] {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func getSubscriptionList(page: Int, limit: Int) async throws -> [Community2Snapshot] {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func subscribeToCommunity(id: Int, subscribe: Bool) async throws -> Community2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func blockCommunity(id: Int, block: Bool) async throws -> Community2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func removeCommunity(
        id: Int,
        remove: Bool,
        reason: String?
    ) async throws -> Community2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func purgeCommunity(id: Int, reason: String?) async throws {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func addModerator(
        communityId: Int,
        personId: Int,
        added: Bool
    ) async throws -> (moderators: [Person1Snapshot], community: Community1Snapshot) {
        throw ApiClientError.unsupportedLemmyVersion
    }
}
