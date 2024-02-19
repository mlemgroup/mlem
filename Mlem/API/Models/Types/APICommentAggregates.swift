//
//  APICommentAggregates.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/CommentAggregates.ts
struct APICommentAggregates: Codable {
    let comment_id: Int
    let score: Int
    let upvotes: Int
    let downvotes: Int
    let published: String
    let child_count: Int

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "comment_id", value: String(comment_id)),
            .init(name: "score", value: String(score)),
            .init(name: "upvotes", value: String(upvotes)),
            .init(name: "downvotes", value: String(downvotes)),
            .init(name: "published", value: published),
            .init(name: "child_count", value: String(child_count))
        ]
    }
}
