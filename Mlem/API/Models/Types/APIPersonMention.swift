//
//  APIPersonMention.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/PersonMention.ts
struct APIPersonMention: Codable {
    let id: Int
    let recipient_id: Int
    let comment_id: Int
    let read: Bool
    let published: String

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "recipient_id", value: String(recipient_id)),
            .init(name: "comment_id", value: String(comment_id)),
            .init(name: "read", value: String(read)),
            .init(name: "published", value: published)
        ]
    }
}
