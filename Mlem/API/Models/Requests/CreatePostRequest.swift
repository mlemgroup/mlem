//
//  CreatePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct CreatePostRequest: APIPostRequest {
    typealias Body = APICreatePost
    typealias Response = APIPostResponse

    let path = "/post"
    let body: Body?

    init(
        name: String,
        communityId: Int,
        url: String,
        body: String,
        honeypot: String,
        nsfw: Bool,
        languageId: Int
    ) {
        self.body = .init(
            name: name,
            community_id: communityId,
            url: url,
            body: body,
            honeypot: honeypot,
            nsfw: nsfw,
            language_id: languageId
        )
    }
}
