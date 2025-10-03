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
        
        guard let published = person.publishedAt ?? person.published else {
            throw .responseMissingRequiredData("LemmyPerson published")
        }

        let instanceBan: InstanceBanType
        if person.banned ?? false { // TODO: We should not be coalescing here! https://github.com/mlemgroup/mlem/issues/2049
            if let expires = person.banExpires {
                instanceBan = .temporarilyBanned(expires: expires)
            } else {
                instanceBan = .permanentlyBanned
            }
        } else {
            instanceBan = .notBanned
        }

        self.init(
            actorId: actorId,
            id: person.id,
            name: person.name,
            created: published,
            instanceId: person.instanceId,
            displayName: person.displayName ?? person.name,
            avatar: person.avatar,
            banner: person.banner,
            updated: person.updatedAt ?? person.updated,
            description: person.bio,
            matrixUserId: person.matrixUserId,
            isBot: person.botAccount,
            instanceBan: instanceBan,
            deleted: person.deleted,
            allPropertiesPresent: true
        )
    }
}
