//
//  MarkPostRead.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-31.
//

import Foundation

struct MarkPostReadRequest: APIPostRequest {
    typealias Response = MarkReadCompatibilityResponse

    let instanceURL: URL
    let path = "post/mark_as_read"
    let body: Body

    struct Body: Encodable {
        let post_id: Int
        let read: Bool
        let auth: String
        // TODO: 0.19 support add post_ids? field
    }

    init(
        session: APISession,
        postId: Int,
        read: Bool
    ) throws {
        self.instanceURL = try session.instanceUrl

        self.body = try .init(
            post_id: postId,
            read: read,
            auth: session.token
        )
    }
}
