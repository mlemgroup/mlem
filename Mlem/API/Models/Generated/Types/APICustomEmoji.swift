//
//  APICustomEmoji.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/CustomEmoji.ts
struct APICustomEmoji: Codable {
    let id: Int
    let local_site_id: Int
    let shortcode: String
    let image_url: String
    let alt_text: String
    let category: String
    let published: Date
    let updated: Date?
}
