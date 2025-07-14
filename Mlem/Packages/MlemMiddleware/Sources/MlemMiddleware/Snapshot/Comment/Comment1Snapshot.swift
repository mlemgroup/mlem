//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-07.
//

import Foundation

public struct Comment1Snapshot: CacheIdentifiable {
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
}
