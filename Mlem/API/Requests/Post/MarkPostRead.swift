//
//  MarkPostRead.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-31.
//

import Foundation

struct MarkPostReadRequest: APIPostRequest {
    typealias Response = PostResponse

    let instanceURL: URL
    let path = "post/mark_as_read"
    let body: Body

    struct Body: Encodable {
        let post_id: Int
        let read: Bool
        let auth: String
    }

    init(
        session: APISession,
        postId: Int,
        read: Bool
    ) {
        self.instanceURL = session.URL

        self.body = .init(
            post_id: postId,
            read: read,
            auth: session.token
        )
    }
}
