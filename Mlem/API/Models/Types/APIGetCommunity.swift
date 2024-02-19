//
//  APIGetCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/GetCommunity.ts
struct APIGetCommunity: Codable {
    let id: Int?
    let name: String?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: id.map(String.init)),
            .init(name: "name", value: name)
        ]
    }
}
