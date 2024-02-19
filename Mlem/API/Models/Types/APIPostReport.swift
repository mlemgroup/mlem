//
//  APIPostReport.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/PostReport.ts
struct APIPostReport: Codable {
    let id: Int
    let creator_id: Int
    let post_id: Int
    let original_post_name: String
    let original_post_url: String?
    let original_post_body: String?
    let reason: String
    let resolved: Bool
    let resolver_id: Int?
    let published: String
    let updated: String?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "creator_id", value: String(creator_id)),
            .init(name: "post_id", value: String(post_id)),
            .init(name: "original_post_name", value: original_post_name),
            .init(name: "original_post_url", value: original_post_url),
            .init(name: "original_post_body", value: original_post_body),
            .init(name: "reason", value: reason),
            .init(name: "resolved", value: String(resolved)),
            .init(name: "resolver_id", value: resolver_id.map(String.init)),
            .init(name: "published", value: published),
            .init(name: "updated", value: updated)
        ]
    }
}
