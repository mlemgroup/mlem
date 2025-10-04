//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-11.
//

import Foundation

public struct Instance1Snapshot: CacheIdentifiable {
    // Won't change.
    public let actorId: ActorIdentifier
    public let id: Int
    public let instanceId: Int
    public let created: Date
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Instance1!
    public let updated: Date?
    public let publicKey: String
    public var displayName: String
    public var description: String?
    public var shortDescription: String?
    public var avatar: URL?
    public var banner: URL?
    public var lastRefresh: Date
    public var contentWarning: String?
    
    public var cacheId: Int { id }
    
    public init(
        actorId: ActorIdentifier,
        id: Int,
        instanceId: Int,
        created: Date,
        updated: Date?,
        publicKey: String,
        displayName: String,
        description: String? = nil,
        shortDescription: String? = nil,
        avatar: URL? = nil,
        banner: URL? = nil,
        lastRefresh: Date,
        contentWarning: String? = nil
    ) {
        self.actorId = actorId
        self.id = id
        self.instanceId = instanceId
        self.created = created
        self.updated = updated
        self.publicKey = publicKey
        self.displayName = displayName
        self.description = description
        self.shortDescription = shortDescription
        self.avatar = avatar
        self.banner = banner
        self.lastRefresh = lastRefresh
        self.contentWarning = contentWarning
    }
}
