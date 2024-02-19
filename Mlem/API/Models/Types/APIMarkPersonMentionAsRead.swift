//
//  APIMarkPersonMentionAsRead.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/MarkPersonMentionAsRead.ts
struct APIMarkPersonMentionAsRead: Codable {
    let person_mention_id: Int
    let read: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "person_mention_id", value: String(person_mention_id)),
            .init(name: "read", value: String(read))
        ]
    }
}
