//
//  LikePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

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
