//
//  EditPost.swift
//  Mlem
//
//  Created by Jonathan de Jong on 13.06.2023.
//

import Foundation

struct DeletePostRequest: APIPostRequest {

    typealias Response = PostResponse

    let instanceURL: URL
    let path = "post/delete"
    let body: Body

    // lemmy_api_common::post::DeletePost
    struct Body: Encodable {
        let post_id: Int
        let deleted: Bool

        let auth: String
    }

    init(
        session: APISession,
        postId: Int,
        deleted: Bool
    ) {
        self.instanceURL = session.URL
        self.body = .init(
            post_id: postId,
            deleted: deleted,
            auth: session.token
        )
    }
}
