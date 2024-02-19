//
//  APIDeleteComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/DeleteComment.ts
struct APIDeleteComment: Codable {
    let comment_id: Int
    let deleted: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "comment_id", value: String(comment_id)),
            .init(name: "deleted", value: String(deleted))
        ]
    }
}
