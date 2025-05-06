//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-04.
//

import Foundation

public struct Community1Snapshot: CacheIdentifiable {
    // Won't change.
    public let actorId: ActorIdentifier
    public let id: Int
    public let name: String
    public let created: Date
    public let instanceId: Int

    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Community1!
    public let updated: Date?
    public let displayName: String
    public let description: String?
    public let deleted: Bool
    public let removed: Bool
    public let nsfw: Bool
    public let avatar: URL?
    public let banner: URL?
    public let hidden: Bool
    public let onlyModeratorsCanPost: Bool
    public let visibility: ApiCommunityVisibility?

    public var cacheId: Int { id }
    
    public init(from community: ApiCommunity) throws(ApiClientError) {
        if let actorId = community.apId ?? community.actorId {
            self.actorId = actorId
        } else {
            throw .responseMissingRequiredData
        }
        
        self.id = community.id
        self.name = community.name
        self.created = community.published
        self.instanceId = community.instanceId
        
        self.updated = community.updated
        self.displayName = community.title
        self.description = community.description
        self.removed = community.removed
        self.deleted = community.deleted
        self.nsfw = community.nsfw
        self.avatar = community.icon
        self.banner = community.banner
        self.hidden = community.hidden ?? false // TODO: 0.20 we shouldn't be null coalescing here
        self.onlyModeratorsCanPost = community.postingRestrictedToMods
        self.visibility = community.visibility
    }
}
