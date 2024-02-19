//
//  APIEditCustomEmoji.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/EditCustomEmoji.ts
struct APIEditCustomEmoji: Codable {
    let id: Int
    let category: String
    let image_url: String
    let alt_text: String
    let keywords: [String]

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
