//
//  APIPersonView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/PersonView.ts
struct APIPersonView: Codable {
    let person: APIPerson
    let counts: APIPersonAggregates
    let is_admin: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
