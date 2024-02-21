//
//  ApiCreateCustomEmoji.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// CreateCustomEmoji.ts
struct ApiCreateCustomEmoji: Codable {
    let category: String
    let shortcode: String
    let imageUrl: String
    let altText: String
    let keywords: [String]
}
