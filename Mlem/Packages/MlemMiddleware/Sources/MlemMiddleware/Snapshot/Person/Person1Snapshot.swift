//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-04.
//

import Foundation

public struct Person1Snapshot: CacheIdentifiable {
    // Won't change.
    public let actorId: ActorIdentifier
    public let id: Int
    public let name: String
    public let created: Date
    public let instanceId: Int

    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Person1!
    public let displayName: String
    public let avatar: URL?

    // https://codeberg.org/rimu/pyfedi/issues/882
    public let banner: MaybePresent<URL>
    // https://codeberg.org/rimu/pyfedi/issues/1961
    public let note: MaybePresent<String>
    public let updated: Date?
    public let description: MaybePresent<String>
    public let matrixUserId: String?
    public let isBot: Bool
    public let instanceBan: InstanceBanType
    public let deleted: Bool

    public var cacheId: Int { id }
    
    public init(
        actorId: ActorIdentifier,
        id: Int,
        name: String,
        created: Date,
        instanceId: Int,
        displayName: String,
        avatar: URL?,
        banner: MaybePresent<URL>,
        note: MaybePresent<String>,
        updated: Date?,
        description: MaybePresent<String>,
        matrixUserId: String?,
        isBot: Bool,
        instanceBan: InstanceBanType,
        deleted: Bool
    ) {
        self.actorId = actorId
        self.id = id
        self.name = name
        self.created = created
        self.instanceId = instanceId
        self.displayName = displayName
        self.avatar = avatar
        self.banner = banner
        self.note = note
        self.updated = updated
        self.description = description
        self.matrixUserId = matrixUserId
        self.isBot = isBot
        self.instanceBan = instanceBan
        self.deleted = deleted
    }
}
