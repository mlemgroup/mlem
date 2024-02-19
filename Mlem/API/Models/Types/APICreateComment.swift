//
//  APICreateComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/CreateComment.ts
struct APICreateComment: Codable {
    let content: String
    let post_id: Int
    let parent_id: Int?
    let language_id: Int?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "content", value: content),
            .init(name: "post_id", value: String(post_id)),
            .init(name: "parent_id", value: parent_id.map(String.init)),
            .init(name: "language_id", value: language_id.map(String.init))
        ]
    }
}
