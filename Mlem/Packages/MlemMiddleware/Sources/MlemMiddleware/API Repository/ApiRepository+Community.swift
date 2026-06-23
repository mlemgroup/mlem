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
    
    func getCommunity(handle: CommunityHandle) async throws -> Community2Snapshot {
        try await performingForConnection { connection in
            try await connection.getCommunity(handle: handle)
        }
    }
    
    func searchCommunities(
        query: String,
        pageInfo: PageInfo,
        filter: ListingType = .all,
        sort: CommunitySortType
    ) async throws -> PagedResponse<Community2Snapshot> {
        try await performingForConnection { connection in
            try await connection.searchCommunities(
                query: query,
                pageInfo: pageInfo,
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
    
    func getSubscriptionList(pageInfo: PageInfo) async throws -> PagedResponse<Community2Snapshot> {
        try await performingForConnection { connection in
            try await connection.getSubscriptionList(pageInfo: pageInfo)
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
