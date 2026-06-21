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
    
    // This isn't technically an API field, but is included here because this information is implicit
    // in the API response (assuming the API is authenticated; otherwise no message should ever be created)
    // and awkward to either populate or synthesize downstream
    public let isOwnMessage: Bool
    
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
        isOwnMessage: Bool,
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
        self.isOwnMessage = isOwnMessage
        self.content = content
        self.updated = updated
        self.read = read
        self.deleted = deleted
    }
}
