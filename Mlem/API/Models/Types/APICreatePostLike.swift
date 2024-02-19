//
//  APICreatePostLike.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/CreatePostLike.ts
struct APICreatePostLike: Codable {
    let post_id: Int
    let score: Int

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "post_id", value: String(post_id)),
            .init(name: "score", value: String(score))
        ]
    }
}
