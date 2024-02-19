//
//  APICommentReport.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/CommentReport.ts
struct APICommentReport: Codable {
    let id: Int
    let creator_id: Int
    let comment_id: Int
    let original_comment_text: String
    let reason: String
    let resolved: Bool
    let resolver_id: Int?
    let published: String
    let updated: String?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "creator_id", value: String(creator_id)),
            .init(name: "comment_id", value: String(comment_id)),
            .init(name: "original_comment_text", value: original_comment_text),
            .init(name: "reason", value: reason),
            .init(name: "resolved", value: String(resolved)),
            .init(name: "resolver_id", value: resolver_id.map(String.init)),
            .init(name: "published", value: published),
            .init(name: "updated", value: updated)
        ]
    }
}
