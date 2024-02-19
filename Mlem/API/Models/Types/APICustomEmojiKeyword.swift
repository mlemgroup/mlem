//
//  APICustomEmojiKeyword.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/CustomEmojiKeyword.ts
struct APICustomEmojiKeyword: Codable {
    let custom_emoji_id: Int
    let keyword: String

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "custom_emoji_id", value: String(custom_emoji_id)),
            .init(name: "keyword", value: keyword)
        ]
    }
}
