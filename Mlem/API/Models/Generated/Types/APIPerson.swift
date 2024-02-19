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
    let id: Int
    let name: String
    let display_name: String?
    let avatar: String?
    let banned: Bool
    let published: Date
    let updated: Date?
    let actor_id: URL
    let bio: String?
    let local: Bool
    let banner: URL?
    let deleted: Bool
    let matrix_user_id: String?
    let bot_account: Bool
    let ban_expires: String?
    let instance_id: Int
}
