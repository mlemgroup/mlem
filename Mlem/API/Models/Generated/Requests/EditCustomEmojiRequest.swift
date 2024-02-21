//
//  EditCustomEmojiRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct EditCustomEmojiRequest: ApiPutRequest {
    typealias Body = ApiEditCustomEmoji
    typealias Response = ApiCustomEmojiResponse

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
            imageUrl: imageUrl,
            altText: altText,
            keywords: keywords
        )
    }
}
