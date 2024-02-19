//
//  LikePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct LikePostRequest: APIPostRequest {
    typealias Body = APICreatePostLike
    typealias Response = APIPostResponse

    let path = "/post/like"
    let body: Body?

    init(
        postId: Int,
        score: Int
    ) {
        self.body = .init(
            post_id: postId,
            score: score
        )
    }
}
