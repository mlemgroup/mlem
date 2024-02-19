//
//  APIDeletePrivateMessage.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/DeletePrivateMessage.ts
struct APIDeletePrivateMessage: Codable {
    let private_message_id: Int
    let deleted: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "private_message_id", value: String(private_message_id)),
            .init(name: "deleted", value: String(deleted))
        ]
    }
}
