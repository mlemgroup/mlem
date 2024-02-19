//
//  CreateCustomEmojiRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct CreateCustomEmojiRequest: APIPostRequest {
    typealias Body = APICreateCustomEmoji
    typealias Response = APICustomEmojiResponse

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
            image_url: imageUrl,
            alt_text: altText,
            keywords: keywords
        )
    }
}
