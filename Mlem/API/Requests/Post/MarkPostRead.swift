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
        let post_id: Int?
        let post_ids: [Int]?
        let read: Bool
        let auth: String
    }

    /// Create a request to mark a single post as read
    init(
        session: APISession,
        postId: Int,
        read: Bool
    ) throws {
        self.instanceURL = try session.instanceUrl

        self.body = try .init(
            post_id: postId,
            post_ids: nil,
            read: read,
            auth: session.token
        )
    }
    
    /// Create a request to mark multiple posts as read
    init(
        session: APISession,
        postIds: [Int],
        read: Bool
    ) throws {
        self.instanceURL = try session.instanceUrl
        
        self.body = try .init(
            post_id: nil,
            post_ids: postIds,
            read: read,
            auth: session.token
        )
    }
}
