//
//  LockPostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct LockPostRequest: APIPostRequest {
    typealias Body = APILockPost
    typealias Response = APIPostResponse

    let path = "/post/lock"
    let body: Body?

    init(
        postId: Int,
        locked: Bool
    ) {
        self.body = .init(
            post_id: postId,
            locked: locked
        )
    }
}
