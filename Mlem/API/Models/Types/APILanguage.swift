//
//  APILanguage.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/Language.ts
struct APILanguage: Codable {
    let id: Int
    let code: String
    let name: String

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "code", value: code),
            .init(name: "name", value: name)
        ]
    }
}
