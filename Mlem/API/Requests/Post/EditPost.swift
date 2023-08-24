//
//  EditPost.swift
//  Mlem
//
//  Created by Jonathan de Jong on 12.06.2023.
//

import Foundation

struct EditPostRequest: APIPutRequest {
    typealias Response = PostResponse

    let instanceURL: URL
    let path = "post"
    let body: Body

    // lemmy_api_common::post::EditPost
    struct Body: Encodable {
        let post_id: Int
        let name: String?
        let url: URL?
        let body: String?
        let nsfw: Bool?
        let language_id: Int?

        let auth: String
    }

    init(
        session: APISession,

        postId: Int,
        name: String?,
        url: String?,
        body: String?,
        nsfw: Bool?,
        languageId: Int?
    ) {
        self.instanceURL = session.URL

        self.body = .init(
            post_id: postId,
            name: name,
            url: URL(string: url ?? ""),
            body: body,
            nsfw: nsfw,
            language_id: languageId,

            auth: session.token
        )
    }
}
