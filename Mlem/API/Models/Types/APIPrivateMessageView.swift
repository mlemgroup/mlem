//
//  APIPrivateMessageView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/PrivateMessageView.ts
struct APIPrivateMessageView: Codable {
    let private_message: APIPrivateMessage
    let creator: APIPerson
    let recipient: APIPerson

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
