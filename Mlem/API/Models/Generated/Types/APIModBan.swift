//
//  APIModBan.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ModBan.ts
struct APIModBan: Codable {
    let id: Int
    let mod_person_id: Int
    let other_person_id: Int
    let reason: String?
    let banned: Bool
    let expires: String?
    let when_: String
}
