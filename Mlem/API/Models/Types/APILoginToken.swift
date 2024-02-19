//
//  APILoginToken.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/LoginToken.ts
struct APILoginToken: Codable {
    let user_id: Int
    let published: String
    let ip: String?
    let user_agent: String?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "user_id", value: String(user_id)),
            .init(name: "published", value: published),
            .init(name: "ip", value: ip),
            .init(name: "user_agent", value: user_agent)
        ]
    }
}
