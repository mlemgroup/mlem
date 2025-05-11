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
    
    public init(from site: ApiSite) throws(ApiClientError) {
        if let actorId = site.apId ?? site.actorId {
            self.actorId = actorId
        } else {
            throw .responseMissingRequiredData
        }
        
        self.id = site.id
        self.instanceId = site.instanceId
        self.created = site.published
        
        self.updated = site.updated
        self.publicKey = site.publicKey
        self.displayName = site.name
        self.description = site.sidebar
        self.shortDescription = site.description
        self.avatar = site.icon
        self.banner = site.banner
        self.lastRefresh = site.lastRefreshedAt
        self.contentWarning = site.contentWarning
    }
}
