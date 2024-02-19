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
    // swiftlint:disable:next identifier_name
    let id: Int
    let category: String
    let imageUrl: String
    let altText: String
    let keywords: [String]
}
