//
//  APIBlockPerson.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/BlockPerson.ts
struct APIBlockPerson: Codable {
    let person_id: Int
    let block: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "person_id", value: String(person_id)),
            .init(name: "block", value: String(block))
        ]
    }
}
