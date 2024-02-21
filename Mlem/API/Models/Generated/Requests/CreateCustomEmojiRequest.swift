//
//  CreateCustomEmojiRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct CreateCustomEmojiRequest: ApiPostRequest {
    typealias Body = ApiCreateCustomEmoji
    typealias Response = ApiCustomEmojiResponse

    let path = "/custom_emoji"
    let body: Body?

    init(
        category: String,
        shortcode: String,
        imageUrl: String,
        altText: String,
        keywords: [String]
    ) {
        self.body = .init(
            category: category,
            shortcode: shortcode,
            imageUrl: imageUrl,
            altText: altText,
            keywords: keywords
        )
    }
}
