//
//  ApiRepository+Community.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-02.
//

import Foundation

extension ApiRepository {
    func getCommunity(id: Int) async throws -> Community3Snapshot {
        try await performingForConnection { connection in
            try await connection.getCommunity(id: id)
        }
    }
    
    func getCommunity(url: URL) async throws -> Community2Snapshot {
        try await performingForConnection { connection in
            try await connection.getCommunity(url: url)
        }
    }
    
    func searchCommunities(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        filter: ListingType = .all,
        sort: CommunitySortType,
        hostApi: ApiClient? = nil
    ) async throws -> [Community2Snapshot] {
        try await performingForConnection { connection in
            try await connection.searchCommunities(
                query: query,
                page: page,
                limit: limit,
                filter: filter,
                sort: sort
            )
        }
    }

    func editCommunityDescription(id: Int, newValue: String?) async throws -> Community2Snapshot {
        try await performingForConnection { connection in
            try await connection.editCommunityDescription(id: id, newValue: newValue)
        }
    }
    
    func getSubscriptionList(page: Int, limit: Int) async throws -> [Community2Snapshot] {
        try await performingForConnection { connection in
            try await connection.getSubscriptionList(page: page, limit: limit)
        }
    }
    
    func subscribeToCommunity(id: Int, subscribe: Bool) async throws -> Community2Snapshot {
        try await performingForConnection { connection in
            try await connection.subscribeToCommunity(id: id, subscribe: subscribe)
        }
    }
    
    func blockCommunity(id: Int, block: Bool, semaphore: UInt? = nil) async throws -> Community2Snapshot {
        try await performingForConnection { connection in
            try await connection.blockCommunity(id: id, block: block)
        }
    }
    
    func removeCommunity(
        id: Int,
        remove: Bool,
        reason: String?
    ) async throws -> Community2Snapshot {
        try await performingForConnection { connection in
            try await connection.removeCommunity(
                id: id,
                remove: remove,
                reason: reason
            )
        }
    }
    
    func purgeCommunity(id: Int, reason: String?) async throws {
        try await performingForConnection { connection in
            try await connection.purgeCommunity(id: id, reason: reason)
        }
    }
    
    func addModerator(communityId: Int, personId: Int, added: Bool) async throws -> (moderators: [Person1Snapshot], community: Community1Snapshot) {
        try await performingForConnection { connection in
            try await connection.addModerator(
                communityId: communityId,
                personId: personId,
                added: added
            )
        }
    }
}
