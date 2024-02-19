//
//  APIPostAggregates.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/PostAggregates.ts
struct APIPostAggregates: Codable {
    let post_id: Int
    let comments: Int
    let score: Int
    let upvotes: Int
    let downvotes: Int
    let published: String
    let newest_comment_time: String

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "post_id", value: String(post_id)),
            .init(name: "comments", value: String(comments)),
            .init(name: "score", value: String(score)),
            .init(name: "upvotes", value: String(upvotes)),
            .init(name: "downvotes", value: String(downvotes)),
            .init(name: "published", value: published),
            .init(name: "newest_comment_time", value: newest_comment_time)
        ]
    }
}
