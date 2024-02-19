//
//  APICreateCommentLike.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/CreateCommentLike.ts
struct APICreateCommentLike: Codable {
    let comment_id: Int
    let score: Int

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "comment_id", value: String(comment_id)),
            .init(name: "score", value: String(score))
        ]
    }
}
