//
//  APIMarkPrivateMessageAsRead.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/MarkPrivateMessageAsRead.ts
struct APIMarkPrivateMessageAsRead: Codable {
    let private_message_id: Int
    let read: Bool

    func toQueryItems() -> [URLQueryItem] {
        return [
            .init(name: "private_message_id", value: String(private_message_id)),
            .init(name: "read", value: String(read))
        ]
    }

}
