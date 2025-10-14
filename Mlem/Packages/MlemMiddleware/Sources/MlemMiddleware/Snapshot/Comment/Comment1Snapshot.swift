//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-07.
//

import Foundation

public struct Comment1Snapshot: CacheIdentifiable, CommentSnapshotProviding {
    // Won't change.
    public let actorId: ActorIdentifier
    public let id: Int
    public let creatorId: Int
    public let postId: Int
    public let parentCommentIds: [Int]
    public let created: Date

    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Comment1!
    public let content: String
    public let updated: Date?
    public let distinguished: Bool
    public let languageId: Int
    public let deleted: Bool
    public let removed: Bool
    
    public var cacheId: Int { id }
    
    public init(
        actorId: ActorIdentifier,
        id: Int,
        creatorId: Int,
        postId: Int,
        parentCommentIds: [Int],
        created: Date,
        content: String,
        updated: Date?,
        distinguished: Bool,
        languageId: Int,
        deleted: Bool,
        removed: Bool
    ) {
        self.actorId = actorId
        self.id = id
        self.creatorId = creatorId
        self.postId = postId
        self.parentCommentIds = parentCommentIds
        self.created = created
        self.content = content
        self.updated = updated
        self.distinguished = distinguished
        self.languageId = languageId
        self.deleted = deleted
        self.removed = removed
    }
    
    public func merge(with snapshot: any CommentSnapshotProviding) -> any CommentSnapshotProviding {
        if snapshot is Comment1Snapshot {
            return self
        }
        if var snapshot2 = snapshot as? Comment2Snapshot {
            snapshot2.comment = self
            return snapshot2
        }
        assertionFailure("Unrecognized snapshot")
        return self
    }
}
