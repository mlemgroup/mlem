//
//  APICreateCustomEmoji.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/CreateCustomEmoji.ts
struct APICreateCustomEmoji: Codable {
    let category: String
    let shortcode: String
    let image_url: String
    let alt_text: String
    let keywords: [String]
}
