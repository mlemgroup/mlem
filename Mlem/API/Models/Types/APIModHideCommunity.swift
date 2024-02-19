//
//  APIModHideCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ModHideCommunity.ts
struct APIModHideCommunity: Codable {
    let id: Int
    let community_id: Int
    let mod_person_id: Int
    let when_: String
    let reason: String?
    let hidden: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "community_id", value: String(community_id)),
            .init(name: "mod_person_id", value: String(mod_person_id)),
            .init(name: "when_", value: when_),
            .init(name: "reason", value: reason),
            .init(name: "hidden", value: String(hidden))
        ]
    }
}
