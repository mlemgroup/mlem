//
//  APIModLockPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ModLockPost.ts
struct APIModLockPost: Codable {
    let id: Int
    let mod_person_id: Int
    let post_id: Int
    let locked: Bool
    let when_: String

    func toQueryItems() -> [URLQueryItem] {
        return [
            .init(name: "id", value: String(id)),
            .init(name: "mod_person_id", value: String(mod_person_id)),
            .init(name: "post_id", value: String(post_id)),
            .init(name: "locked", value: String(locked)),
            .init(name: "when_", value: when_)
        ]
    }

}
