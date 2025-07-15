//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Person1Snapshot {
    init(from person: LemmyPerson) throws(ApiClientError) {
        guard let actorId = person.apId ?? person.actorId else {
            throw .responseMissingRequiredData("LemmyPerson actorId")
        }
        
        self.actorId = actorId
        self.id = person.id
        self.name = person.name
        self.displayName = person.displayName ?? person.name
        self.avatar = person.avatar
        self.banner = person.banner
        
        if let published = person.publishedAt ?? person.published {
            self.created = published
        } else {
            throw .responseMissingRequiredData("LemmyPerson published")
        }
        self.updated = person.updatedAt ?? person.updated
        
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
        
        self.allPropertiesPresent = true
    }
}
