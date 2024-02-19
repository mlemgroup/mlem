//
//  APIPersonBlockView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/PersonBlockView.ts
struct APIPersonBlockView: Codable {
    let person: APIPerson
    let target: APIPerson

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
