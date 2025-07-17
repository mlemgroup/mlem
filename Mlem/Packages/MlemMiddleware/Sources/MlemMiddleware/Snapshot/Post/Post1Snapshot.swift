//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-06.
//

import Foundation

public struct Post1Snapshot: CacheIdentifiable, PostSnapshotProviding {
    // Won't change.
    public let actorId: ActorIdentifier
    public let id: Int
    public let creatorId: Int
    public let communityId: Int
    public let created: Date
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Post1!
    public let title: String
    public let content: String?
    public let linkUrl: URL?
    public let embed: PostEmbed?
    public let nsfw: Bool
    public let thumbnailUrl: URL?
    public let updated: Date?
    public let languageId: Int
    public let altText: String?
    public let deleted: Bool
    public let removed: Bool
    public let pinnedCommunity: Bool
    public let pinnedInstance: Bool
    public let locked: Bool

    public var cacheId: Int { id }
    
    public func merge(with snapshot: any PostSnapshotProviding) -> any PostSnapshotProviding {
        if snapshot is Post1Snapshot {
            return self
        }
        if var snapshot2 = snapshot as? Post2Snapshot {
            snapshot2.post = self
            return snapshot2
        }
        if var snapshot3 = snapshot as? Post3Snapshot {
            snapshot3.post.post = self
            return snapshot3
        }
        assertionFailure("Unrecognized snapshot")
        return self
    }
}
