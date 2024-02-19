//
//  APIEditComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/EditComment.ts
struct APIEditComment: Codable {
    let comment_id: Int
    let content: String?
    let language_id: Int?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "comment_id", value: String(comment_id)),
            .init(name: "content", value: content),
            .init(name: "language_id", value: language_id.map(String.init))
        ]
    }
}
