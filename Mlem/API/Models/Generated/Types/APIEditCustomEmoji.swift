//
//  APIEditCustomEmoji.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/EditCustomEmoji.ts
struct APIEditCustomEmoji: Codable {
    let id: Int
    let category: String
    let image_url: String
    let alt_text: String
    let keywords: [String]
}
