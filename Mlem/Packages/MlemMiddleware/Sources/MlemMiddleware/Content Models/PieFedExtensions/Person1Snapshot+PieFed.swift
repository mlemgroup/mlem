//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Person1Snapshot {
    init(from person: PieFedPerson, descriptionAndBannerProvided: Bool = false, noteProvided: Bool = false) throws(ApiClientError) {
        self.init(
            actorId: person.actorId,
            id: person.id,
            name: person.userName,
            created: person.published,
            instanceId: person.instanceId,
            displayName: person.title ?? person.userName,
            avatar: person.avatar,
            banner: descriptionAndBannerProvided ? .fromOptional(person.banner) : .notProvided,
            note: noteProvided ? .fromOptional(person.note) : .notProvided,
            updated: nil,
            description: descriptionAndBannerProvided ? .fromOptional(person.about) : .notProvided,
            matrixUserId: nil,
            isBot: person.bot,
            // Does PieFed not have bans with expiry times, or did they just not put it in the API yet?
            instanceBan: person.banned ? .permanentlyBanned : .notBanned,
            deleted: person.deleted
        )
    }
}
