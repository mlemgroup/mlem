//
//  LikePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-25
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct LikePostRequest: ApiPostRequest {
    typealias Body = ApiCreatePostLike
    typealias Response = ApiPostResponse

    let path = "/post/like"
    let body: Body?

    init(
        postId: Int,
        score: Int
    ) {
        self.body = .init(
            postId: postId,
            score: score
        )
    }
}
