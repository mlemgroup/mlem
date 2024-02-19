//
//  APIGetPrivateMessages.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/GetPrivateMessages.ts
struct APIGetPrivateMessages: Codable {
    let unread_only: Bool?
    let page: Int?
    let limit: Int?
    let creator_id: Int?

    func toQueryItems() -> [URLQueryItem] {
        return [
            .init(name: "unread_only", value: unread_only.map(String.init)),
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init)),
            .init(name: "creator_id", value: creator_id.map(String.init))
        ]
    }

}
