//
//  APIPerson.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::source::person::PersonSafe
struct APIPerson: Decodable, Identifiable, Hashable, Equatable {
    let id: Int
    let name: String
    var displayName: String?
    var avatar: String?
    var banned: Bool
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

extension APIPerson {
    var avatarUrl: URL? { LemmyURL(string: avatar)?.url }
    var bannerUrl: URL? { LemmyURL(string: banner)?.url }
    var sharedInboxLink: URL? { LemmyURL(string: sharedInboxUrl)?.url }
}
