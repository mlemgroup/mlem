//
//  PieFedGetModlogResponse+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-12.
//


public extension PieFedGetModLogResponse {
    func toSnapshots() throws(ApiClientError) -> [ModlogEntrySnapshot] {
        var result = try (removedPosts).map(ModlogEntrySnapshot.init)
        result += try (lockedPosts).map(ModlogEntrySnapshot.init)
        result += try (featuredPosts).map(ModlogEntrySnapshot.init)
        result += try (removedComments).map(ModlogEntrySnapshot.init)
        result += try (removedCommunities).map(ModlogEntrySnapshot.init)
        result += try (bannedFromCommunity).map(ModlogEntrySnapshot.init)
        result += try (banned).map(ModlogEntrySnapshot.init)
        result += try (addedToCommunity).map(ModlogEntrySnapshot.init)
        result += try (transferredToCommunity).map(ModlogEntrySnapshot.init)
        result += try (added).map(ModlogEntrySnapshot.init)
        result += try (adminPurgedPersons).map(ModlogEntrySnapshot.init)
        result += try (adminPurgedCommunities).map(ModlogEntrySnapshot.init)
        result += try (adminPurgedPosts).map(ModlogEntrySnapshot.init)
        result += try (adminPurgedComments).map(ModlogEntrySnapshot.init)
        result += try (hiddenCommunities).map(ModlogEntrySnapshot.init)
        return result
    }
}
