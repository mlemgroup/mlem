//
//  APIPurgeComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/PurgeComment.ts
struct APIPurgeComment: Codable {
    let comment_id: Int
    let reason: String?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "comment_id", value: String(comment_id)),
            .init(name: "reason", value: reason)
        ]
    }
}
