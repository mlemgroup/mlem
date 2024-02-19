//
//  APIRemovePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/RemovePost.ts
struct APIRemovePost: Codable {
    let post_id: Int
    let removed: Bool
    let reason: String?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "post_id", value: String(post_id)),
            .init(name: "removed", value: String(removed)),
            .init(name: "reason", value: reason)
        ]
    }
}
