//
//  APIComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/Comment.ts
struct APIComment: Codable {
    let id: Int
    let creator_id: Int
    let post_id: Int
    let content: String
    let removed: Bool
    let published: String
    let updated: String?
    let deleted: Bool
    let ap_id: String
    let local: Bool
    let path: String
    let distinguished: Bool
    let language_id: Int

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "creator_id", value: String(creator_id)),
            .init(name: "post_id", value: String(post_id)),
            .init(name: "content", value: content),
            .init(name: "removed", value: String(removed)),
            .init(name: "published", value: published),
            .init(name: "updated", value: updated),
            .init(name: "deleted", value: String(deleted)),
            .init(name: "ap_id", value: ap_id),
            .init(name: "local", value: String(local)),
            .init(name: "path", value: path),
            .init(name: "distinguished", value: String(distinguished)),
            .init(name: "language_id", value: String(language_id))
        ]
    }
}
