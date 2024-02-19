//
//  APIListCommentLikes.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ListCommentLikes.ts
struct APIListCommentLikes: Codable {
    let comment_id: Int
    let page: Int?
    let limit: Int?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "comment_id", value: String(comment_id)),
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init))
        ]
    }
}
