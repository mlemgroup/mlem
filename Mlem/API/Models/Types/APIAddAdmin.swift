//
//  APIAddAdmin.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/AddAdmin.ts
struct APIAddAdmin: Codable {
    let person_id: Int
    let added: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "person_id", value: String(person_id)),
            .init(name: "added", value: String(added))
        ]
    }
}
