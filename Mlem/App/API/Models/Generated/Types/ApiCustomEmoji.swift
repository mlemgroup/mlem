//
//  ApiCustomEmoji.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// CustomEmoji.ts
struct ApiCustomEmoji: Codable {
    let id: Int
    let localSiteId: Int
    let shortcode: String
    let imageUrl: String
    let altText: String
    let category: String
    let published: Date
    let updated: Date?
}
