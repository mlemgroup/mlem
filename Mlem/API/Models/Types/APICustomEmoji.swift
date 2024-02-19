//
//  APICustomEmoji.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/CustomEmoji.ts
struct APICustomEmoji: Codable {
    let id: Int
    let local_site_id: Int
    let shortcode: String
    let image_url: String
    let alt_text: String
    let category: String
    let published: String
    let updated: String?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "local_site_id", value: String(local_site_id)),
            .init(name: "shortcode", value: shortcode),
            .init(name: "image_url", value: image_url),
            .init(name: "alt_text", value: alt_text),
            .init(name: "category", value: category),
            .init(name: "published", value: published),
            .init(name: "updated", value: updated)
        ]
    }
}
