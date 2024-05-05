//
//  RemovePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

struct RemovePostRequest: APIPostRequest {
    typealias Response = APIPostResponse
    
    var instanceURL: URL
    let path = "post/remove"
    let body: Body
    
    struct Body: Codable {
        let post_id: Int
        let removed: Bool
        let reason: String?
        let auth: String
    }
    
    init(
        session: APISession,
        postId: Int,
        removed: Bool,
        reason: String?
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.body = try .init(
            post_id: postId,
            removed: removed,
            reason: reason,
            auth: session.token
        )
    }
}
