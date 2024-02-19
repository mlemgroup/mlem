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
    // swiftlint:disable:next identifier_name
    let id: Int
    let localSiteId: Int
    let shortcode: String
    let imageUrl: String
    let altText: String
    let category: String
    let published: Date
    let updated: Date?
}
