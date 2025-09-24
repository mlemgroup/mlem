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
    
    // This is a dodgy workaround for https://codeberg.org/rimu/pyfedi/issues/882
    // TODO: If that issue gets fixed, we can remove this
    public let allPropertiesPresent: Bool

    public var cacheId: Int { id }
    
    public init(
        actorId: ActorIdentifier,
        id: Int,
        name: String,
        created: Date,
        instanceId: Int,
        updated: Date?,
        displayName: String,
        description: String?,
        deleted: Bool,
        removed: Bool,
        nsfw: Bool,
        avatar: URL?,
        banner: URL?,
        hidden: Bool,
        onlyModeratorsCanPost: Bool,
        allPropertiesPresent: Bool
    ) {
        self.actorId = actorId
        self.id = id
        self.name = name
        self.created = created
        self.instanceId = instanceId
        self.updated = updated
        self.displayName = displayName
        self.description = description
        self.deleted = deleted
        self.removed = removed
        self.nsfw = nsfw
        self.avatar = avatar
        self.banner = banner
        self.hidden = hidden
        self.onlyModeratorsCanPost = onlyModeratorsCanPost
        self.allPropertiesPresent = allPropertiesPresent
    }
}
