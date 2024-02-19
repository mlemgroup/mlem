//
//  APITagline.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/Tagline.ts
struct APITagline: Codable {
    let id: Int
    let local_site_id: Int
    let content: String
    let published: String
    let updated: String?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "local_site_id", value: String(local_site_id)),
            .init(name: "content", value: content),
            .init(name: "published", value: published),
            .init(name: "updated", value: updated)
        ]
    }
}
