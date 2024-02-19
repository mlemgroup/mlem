//
//  APIModRemoveCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ModRemoveCommunity.ts
struct APIModRemoveCommunity: Codable {
    let id: Int
    let mod_person_id: Int
    let community_id: Int
    let reason: String?
    let removed: Bool
    let when_: String

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "mod_person_id", value: String(mod_person_id)),
            .init(name: "community_id", value: String(community_id)),
            .init(name: "reason", value: reason),
            .init(name: "removed", value: String(removed)),
            .init(name: "when_", value: when_)
        ]
    }
}
