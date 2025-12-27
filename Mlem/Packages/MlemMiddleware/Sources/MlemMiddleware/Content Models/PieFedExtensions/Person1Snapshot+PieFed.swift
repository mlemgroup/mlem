//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Person1Snapshot {
    init(from person: PieFedPerson, allPropertiesPresent: Bool = false) throws(ApiClientError) {
        self.init(
            actorId: person.actorId,
            id: person.id,
            name: person.userName,
            created: person.published,
            instanceId: person.instanceId,
            displayName: person.title ?? person.userName,
            avatar: person.avatar,
            banner: person.banner,
            note: person.note,
            updated: nil,
            description: person.about,
            matrixUserId: nil,
            isBot: person.bot,
            // Does PieFed not have bans with expiry times, or did they just not put it in the API yet?
            instanceBan: person.banned ? .permanentlyBanned : .notBanned,
            deleted: person.deleted,
            allPropertiesPresent: allPropertiesPresent
        )
    }
}
