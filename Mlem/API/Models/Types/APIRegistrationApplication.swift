//
//  APIRegistrationApplication.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/RegistrationApplication.ts
struct APIRegistrationApplication: Codable {
    let id: Int
    let local_user_id: Int
    let answer: String
    let admin_id: Int?
    let deny_reason: String?
    let published: String

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "local_user_id", value: String(local_user_id)),
            .init(name: "answer", value: answer),
            .init(name: "admin_id", value: admin_id.map(String.init)),
            .init(name: "deny_reason", value: deny_reason),
            .init(name: "published", value: published)
        ]
    }
}
