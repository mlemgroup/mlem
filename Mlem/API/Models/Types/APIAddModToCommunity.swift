//
//  APIAddModToCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/AddModToCommunity.ts
struct APIAddModToCommunity: Codable {
    let community_id: Int
    let person_id: Int
    let added: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "community_id", value: String(community_id)),
            .init(name: "person_id", value: String(person_id)),
            .init(name: "added", value: String(added))
        ]
    }
}
