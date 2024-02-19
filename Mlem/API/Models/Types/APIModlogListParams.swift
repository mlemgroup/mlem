//
//  APIModlogListParams.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ModlogListParams.ts
struct APIModlogListParams: Codable {
    let community_id: Int?
    let mod_person_id: Int?
    let other_person_id: Int?
    let page: Int?
    let limit: Int?
    let hide_modlog_names: Bool

    func toQueryItems() -> [URLQueryItem] {
        return [
            .init(name: "community_id", value: community_id.map(String.init)),
            .init(name: "mod_person_id", value: mod_person_id.map(String.init)),
            .init(name: "other_person_id", value: other_person_id.map(String.init)),
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init)),
            .init(name: "hide_modlog_names", value: String(hide_modlog_names))
        ]
    }

}
