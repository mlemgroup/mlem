//
//  APIPerson.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

struct APIPerson: Decodable {
    let actorId: URL
    let admin: Bool
    let avatar: URL?
    let banExpires: String?
    let banned: Bool
    let banner: URL?
    let bio: String?
    let botAccount: Bool?
    let deleted: Bool
    let displayName: String?
    let id: Int
    let inboxUrl: URL
    let instanceId: Int
    let local: Bool
    let matrixUserId: String?
    let name: String
    let published: String
    let sharedInboxUrl: URL?
    let updated: String?
}
