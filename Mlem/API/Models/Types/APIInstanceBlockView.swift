//
//  APIInstanceBlockView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/InstanceBlockView.ts
struct APIInstanceBlockView: Codable {
    let person: APIPerson
    let instance: APIInstance
    let site: APISite?

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
