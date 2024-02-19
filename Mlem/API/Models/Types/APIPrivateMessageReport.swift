//
//  APIPrivateMessageReport.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/PrivateMessageReport.ts
struct APIPrivateMessageReport: Codable {
    let id: Int
    let creator_id: Int
    let private_message_id: Int
    let original_pm_text: String
    let reason: String
    let resolved: Bool
    let resolver_id: Int?
    let published: String
    let updated: String?

    func toQueryItems() -> [URLQueryItem] {
        return [
            .init(name: "id", value: String(id)),
            .init(name: "creator_id", value: String(creator_id)),
            .init(name: "private_message_id", value: String(private_message_id)),
            .init(name: "original_pm_text", value: original_pm_text),
            .init(name: "reason", value: reason),
            .init(name: "resolved", value: String(resolved)),
            .init(name: "resolver_id", value: resolver_id.map(String.init)),
            .init(name: "published", value: published),
            .init(name: "updated", value: updated)
        ]
    }

}
