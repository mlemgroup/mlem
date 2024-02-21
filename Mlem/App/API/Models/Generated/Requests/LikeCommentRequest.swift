//
//  LikeCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct LikeCommentRequest: ApiPostRequest {
    typealias Body = ApiCreateCommentLike
    typealias Response = ApiCommentResponse

    let path = "/comment/like"
    let body: Body?

    init(
        commentId: Int,
        score: Int
    ) {
        self.body = .init(
            commentId: commentId,
            score: score
        )
    }
}
