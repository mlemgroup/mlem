//
//  APIPurgePerson.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/PurgePerson.ts
struct APIPurgePerson: Codable {
    let person_id: Int
    let reason: String?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "person_id", value: String(person_id)),
            .init(name: "reason", value: reason)
        ]
    }
}
