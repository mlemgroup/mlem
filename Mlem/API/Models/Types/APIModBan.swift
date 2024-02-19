//
//  APIModBan.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ModBan.ts
struct APIModBan: Codable {
    let id: Int
    let mod_person_id: Int
    let other_person_id: Int
    let reason: String?
    let banned: Bool
    let expires: String?
    let when_: String

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "mod_person_id", value: String(mod_person_id)),
            .init(name: "other_person_id", value: String(other_person_id)),
            .init(name: "reason", value: reason),
            .init(name: "banned", value: String(banned)),
            .init(name: "expires", value: expires),
            .init(name: "when_", value: when_)
        ]
    }
}
