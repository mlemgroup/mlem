//
//  EditPostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct EditPostRequest: APIPutRequest {
    typealias Body = APIEditPost
    typealias Response = APIPostResponse

    let path = "/post"
    let body: Body?

    init(
        postId: Int,
        name: String,
        url: String,
        body: String,
        nsfw: Bool,
        languageId: Int
    ) {
        self.body = .init(
            post_id: postId,
            name: name,
            url: url,
            body: body,
            nsfw: nsfw,
            language_id: languageId
        )
    }
}
