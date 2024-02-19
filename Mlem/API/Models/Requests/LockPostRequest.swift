//
//  LockPostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

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
