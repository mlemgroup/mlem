//
//  LikeCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct LikeCommentRequest: APIPostRequest {
    typealias Body = APICreateCommentLike
    typealias Response = APICommentResponse

    let path = "/comment/like"
    let body: Body?

    init(
        commentId: Int,
        score: Int
    ) {
        self.body = .init(
            comment_id: commentId,
            score: score
        )
    }
}
