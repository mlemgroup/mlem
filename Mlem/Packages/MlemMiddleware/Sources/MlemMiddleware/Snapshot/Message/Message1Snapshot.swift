//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-10.
//

import Foundation

public struct Message1Snapshot: CacheIdentifiable {
    // Won't change.
    public let actorId: ActorIdentifier
    public let id: Int
    public let creatorId: Int
    public let recipientId: Int
    public let created: Date
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Message1!
    public let content: String
    public let updated: Date?
    public let read: Bool
    public let deleted: Bool
    
    public var cacheId: Int { id }
    
    public init(
        actorId: ActorIdentifier,
        id: Int,
        creatorId: Int,
        recipientId: Int,
        created: Date,
        content: String,
        updated: Date?,
        read: Bool,
        deleted: Bool
    ) {
        self.actorId = actorId
        self.id = id
        self.creatorId = creatorId
        self.recipientId = recipientId
        self.created = created
        self.content = content
        self.updated = updated
        self.read = read
        self.deleted = deleted
    }
}
