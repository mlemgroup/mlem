//
//  APIAdminPurgeCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/AdminPurgeCommunity.ts
struct APIAdminPurgeCommunity: Codable {
    let id: Int
    let admin_person_id: Int
    let reason: String?
    let when_: String

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "admin_person_id", value: String(admin_person_id)),
            .init(name: "reason", value: reason),
            .init(name: "when_", value: when_)
        ]
    }
}
