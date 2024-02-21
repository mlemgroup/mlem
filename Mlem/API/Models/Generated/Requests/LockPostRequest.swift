//
//  LockPostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct LockPostRequest: ApiPostRequest {
    typealias Body = ApiLockPost
    typealias Response = ApiPostResponse

    let path = "/post/lock"
    let body: Body?

    init(
        postId: Int,
        locked: Bool
    ) {
        self.body = .init(
            postId: postId,
            locked: locked
        )
    }
}
