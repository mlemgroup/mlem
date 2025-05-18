//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-17.
//

import Foundation

public extension ApiGetModlogResponse {
    func toSnapshots() throws(ApiClientError) -> [ModlogEntrySnapshot] {
        var result = try (removedPosts ?? []).map(ModlogEntrySnapshot.init)
        result += try (lockedPosts ?? []).map(ModlogEntrySnapshot.init)
        result += try (featuredPosts ?? []).map(ModlogEntrySnapshot.init)
        result += try (removedComments ?? []).map(ModlogEntrySnapshot.init)
        result += try (removedCommunities ?? []).map(ModlogEntrySnapshot.init)
        result += try (bannedFromCommunity ?? []).map(ModlogEntrySnapshot.init)
        result += try (banned ?? []).map(ModlogEntrySnapshot.init)
        result += try (addedToCommunity ?? []).map(ModlogEntrySnapshot.init)
        result += try (transferredToCommunity ?? []).map(ModlogEntrySnapshot.init)
        result += try (added ?? []).map(ModlogEntrySnapshot.init)
        result += try (adminPurgedPersons ?? []).map(ModlogEntrySnapshot.init)
        result += try (adminPurgedCommunities ?? []).map(ModlogEntrySnapshot.init)
        result += try (adminPurgedPosts ?? []).map(ModlogEntrySnapshot.init)
        result += try (adminPurgedComments ?? []).map(ModlogEntrySnapshot.init)
        result += try (hiddenCommunities ?? []).map(ModlogEntrySnapshot.init)
        return result
    }
}
