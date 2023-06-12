//
//  APIPerson.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::source::person::PersonSafe
struct APIPerson: Decodable {
    let id: Int
    let name: String
    let displayName: String?
    let avatar: URL?
    let banned: Bool
    let published: String
    let updated: Date?
    let actorId: URL
    let bio: String?
    let local: Bool
    let banner: URL?
    let deleted: Bool
    let inboxUrl: URL
    let sharedInboxUrl: URL?
    let matrixUserId: String?
    let admin: Bool
    let botAccount: Bool
    let banExpires: Date?
    let instanceId: Int
}
