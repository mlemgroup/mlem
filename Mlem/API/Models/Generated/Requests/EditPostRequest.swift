//
//  EditPostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct EditPostRequest: APIPutRequest {
    typealias Body = APIEditPost
    typealias Response = APIPostResponse

    let path = "/post"
    let body: Body?

    init(
        postId: Int,
        name: String?,
        url: String?,
        body: String?,
        nsfw: Bool?,
        languageId: Int?
    ) {
        self.body = .init(
            postId: postId,
            name: name,
            url: url,
            body: body,
            nsfw: nsfw,
            languageId: languageId
        )
    }
}
