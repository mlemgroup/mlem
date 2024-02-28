//
//  LockPostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct LockPostRequest: APIPostRequest {
    typealias Response = ApiPostResponse
    
    var instanceURL: URL
    let path = "post/lock"
    let body: Body
    
    struct Body: Codable {
        let post_id: Int
        let locked: Bool
        let auth: String
    }
    
    init(
        session: APISession,
        postId: Int,
        locked: Bool
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.body = try .init(
            post_id: postId,
            locked: locked,
            auth: session.token
        )
    }
}
