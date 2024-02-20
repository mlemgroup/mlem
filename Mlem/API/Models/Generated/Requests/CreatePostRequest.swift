//
//  CreatePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct CreatePostRequest: APIPostRequest {
    typealias Body = APICreatePost
    typealias Response = APIPostResponse

    let path = "/post"
    let body: Body?

    init(
        name: String,
        communityId: Int,
        url: String?,
        body: String?,
        honeypot: String?,
        nsfw: Bool?,
        languageId: Int?
    ) {
        self.body = .init(
            name: name,
            communityId: communityId,
            url: url,
            body: body,
            honeypot: honeypot,
            nsfw: nsfw,
            languageId: languageId
        )
    }
}
