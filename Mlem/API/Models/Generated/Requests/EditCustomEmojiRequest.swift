//
//  EditCustomEmojiRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct EditCustomEmojiRequest: APIPutRequest {
    typealias Body = APIEditCustomEmoji
    typealias Response = APICustomEmojiResponse

    let path = "/custom_emoji"
    let body: Body?

    init(
        id: Int,
        category: String,
        imageUrl: String,
        altText: String,
        keywords: [String]
    ) {
        self.body = .init(
            id: id,
            category: category,
            image_url: imageUrl,
            alt_text: altText,
            keywords: keywords
        )
    }
}
