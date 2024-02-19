//
//  APICustomEmojiView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/CustomEmojiView.ts
struct APICustomEmojiView: Codable {
    let custom_emoji: APICustomEmoji
    let keywords: [APICustomEmojiKeyword]

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
