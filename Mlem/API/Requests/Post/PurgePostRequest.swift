//
//  PurgePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

struct PurgePostRequest: APIPostRequest {
    typealias Response = SuccessResponse

    var instanceURL: URL
    let path = "admin/purge/post"
    let body: Body
    
    struct Body: Codable {
        let post_id: Int
        let reason: String?
        let auth: String
    }

    init(
        session: APISession,
        postId: Int,
        reason: String?
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.body = try .init(
            post_id: postId,
            reason: reason,
            auth: session.token
        )
    }
}
