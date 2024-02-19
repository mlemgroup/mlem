//
//  APIModFeaturePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ModFeaturePost.ts
struct APIModFeaturePost: Codable {
    let id: Int
    let mod_person_id: Int
    let post_id: Int
    let featured: Bool
    let when_: String
    let is_featured_community: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "mod_person_id", value: String(mod_person_id)),
            .init(name: "post_id", value: String(post_id)),
            .init(name: "featured", value: String(featured)),
            .init(name: "when_", value: when_),
            .init(name: "is_featured_community", value: String(is_featured_community))
        ]
    }
}
