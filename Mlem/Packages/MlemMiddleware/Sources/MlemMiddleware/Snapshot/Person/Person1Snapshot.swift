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
    public let banner: URL?
    public let updated: Date?
    public let description: String?
    public let matrixUserId: String?
    public let isBot: Bool
    public let instanceBan: InstanceBanType
    public let deleted: Bool
    
    public var cacheId: Int { id }
    
    public init(from person: ApiPerson) throws(ApiClientError) {
        guard let actorId = person.apId ?? person.actorId else {
            throw .responseMissingRequiredData("ApiPerson actorId")
        }
        
        self.actorId = actorId
        self.id = person.id
        self.name = person.name
        self.displayName = person.displayName ?? person.name
        self.avatar = person.avatar
        self.banner = person.banner
        self.created = person.published
        self.updated = person.updated
        self.description = person.bio
        self.matrixUserId = person.matrixUserId
        self.isBot = person.botAccount
        self.deleted = person.deleted
        self.instanceId = person.instanceId
        
        if person.banned ?? false { // TODO: We should not be coalescing here! https://github.com/mlemgroup/mlem/issues/2049
            if let expires = person.banExpires {
                self.instanceBan = .temporarilyBanned(expires: expires)
            } else {
                self.instanceBan = .permanentlyBanned
            }
        } else {
            self.instanceBan = .notBanned
        }
    }
}
