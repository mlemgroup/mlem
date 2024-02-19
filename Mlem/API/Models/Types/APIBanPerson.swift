//
//  APIBanPerson.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/BanPerson.ts
struct APIBanPerson: Codable {
    let person_id: Int
    let ban: Bool
    let remove_data: Bool?
    let reason: String?
    let expires: Int?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "person_id", value: String(person_id)),
            .init(name: "ban", value: String(ban)),
            .init(name: "remove_data", value: remove_data.map(String.init)),
            .init(name: "reason", value: reason),
            .init(name: "expires", value: expires.map(String.init))
        ]
    }
}
