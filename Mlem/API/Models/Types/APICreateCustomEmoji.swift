//
//  APICreateCustomEmoji.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/CreateCustomEmoji.ts
struct APICreateCustomEmoji: Codable {
    let category: String
    let shortcode: String
    let image_url: String
    let alt_text: String
    let keywords: [String]

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
