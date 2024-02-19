//
//  APIPrivateMessage.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/PrivateMessage.ts
struct APIPrivateMessage: Codable {
    let id: Int
    let creator_id: Int
    let recipient_id: Int
    let content: String
    let deleted: Bool
    let read: Bool
    let published: String
    let updated: String?
    let ap_id: String
    let local: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "creator_id", value: String(creator_id)),
            .init(name: "recipient_id", value: String(recipient_id)),
            .init(name: "content", value: content),
            .init(name: "deleted", value: String(deleted)),
            .init(name: "read", value: String(read)),
            .init(name: "published", value: published),
            .init(name: "updated", value: updated),
            .init(name: "ap_id", value: ap_id),
            .init(name: "local", value: String(local))
        ]
    }
}
