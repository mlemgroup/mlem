//
//  APIPerson.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/Person.ts
struct APIPerson: Codable {
    // swiftlint:disable:next identifier_name
    let id: Int
    let name: String
    let displayName: String?
    let avatar: URL?
    let banned: Bool
    let published: Date
    let updated: Date?
    let actorId: URL
    let bio: String?
    let local: Bool
    let banner: URL?
    let deleted: Bool
    let matrixUserId: String?
    let botAccount: Bool
    let banExpires: Date?
    let instanceId: Int
}
