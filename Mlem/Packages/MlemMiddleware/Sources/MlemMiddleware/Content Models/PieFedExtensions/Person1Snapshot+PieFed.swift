//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Person1Snapshot {
    init(from person: PieFedPerson) throws(ApiClientError) {
        self.actorId = person.actorId
        self.id = person.id
        self.name = person.userName
        self.displayName = person.title ?? person.userName
        self.avatar = person.avatar
        self.banner = person.banner
        self.created = person.published
        
        self.updated = nil
        self.description = nil
        self.matrixUserId = nil
        
        self.isBot = person.bot
        self.deleted = person.deleted
        self.instanceId = person.instanceId
        
        // Does PieFed not have bans with expiry times, or did they just not put it in the API yet?
        self.instanceBan = person.banned ? .permanentlyBanned : .notBanned
    }
}
