//
//  APIPerson.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::source::person::PersonSafe
struct APIPerson: Decodable, ActorIdentifiable, Identifiable, Hashable, Equatable {
    internal init(
        id: Int = 0,
        name: String = "Mock Person",
        displayName: String? = nil,
        avatar: String? = nil,
        banned: Bool = false,
        published: Date = .mock,
        updated: Date? = nil,
        actorId: URL = .mock,
        bio: String? = nil,
        local: Bool = false,
        banner: String? = nil,
        deleted: Bool = false,
        sharedInboxUrl: String? = nil,
        matrixUserId: String? = nil,
        admin: Bool = false,
        botAccount: Bool = false,
        banExpires: Date? = nil,
        instanceId: Int = 0
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.avatar = avatar
        self.banned = banned
        self.published = published
        self.updated = updated
        self.actorId = actorId
        self.bio = bio
        self.local = local
        self.banner = banner
        self.deleted = deleted
        self.sharedInboxUrl = sharedInboxUrl
        self.matrixUserId = matrixUserId
        self.admin = admin
        self.botAccount = botAccount
        self.banExpires = banExpires
        self.instanceId = instanceId
    }
    
    let id: Int
    let name: String
    var displayName: String?
    var avatar: String?
    let banned: Bool
    let published: Date
    let updated: Date?
    let actorId: URL
    var bio: String?
    let local: Bool
    var banner: String?
    let deleted: Bool
    let sharedInboxUrl: String?
    var matrixUserId: String?
    let admin: Bool? // TODO: 0.18 deprecation remove this field
    var botAccount: Bool
    let banExpires: Date?
    let instanceId: Int
}

extension APIPerson: Mockable {
    static var mock: APIPerson = .init()
}

extension APIPerson {
    var avatarUrl: URL? { LemmyURL(string: avatar)?.url }
    var bannerUrl: URL? { LemmyURL(string: banner)?.url }
    var sharedInboxLink: URL? { LemmyURL(string: sharedInboxUrl)?.url }
}
