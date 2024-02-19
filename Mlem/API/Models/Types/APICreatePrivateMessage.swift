//
//  APICreatePrivateMessage.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/CreatePrivateMessage.ts
struct APICreatePrivateMessage: Codable {
    let content: String
    let recipient_id: Int

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "content", value: content),
            .init(name: "recipient_id", value: String(recipient_id))
        ]
    }
}
