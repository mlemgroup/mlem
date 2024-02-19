//
//  APICreatePrivateMessageReport.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/CreatePrivateMessageReport.ts
struct APICreatePrivateMessageReport: Codable {
    let private_message_id: Int
    let reason: String

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "private_message_id", value: String(private_message_id)),
            .init(name: "reason", value: reason)
        ]
    }
}
