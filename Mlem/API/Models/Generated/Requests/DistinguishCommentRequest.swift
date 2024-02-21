//
//  DistinguishCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct DistinguishCommentRequest: ApiPostRequest {
    typealias Body = ApiDistinguishComment
    typealias Response = ApiCommentResponse

    let path = "/comment/distinguish"
    let body: Body?

    init(
        commentId: Int,
        distinguished: Bool
    ) {
        self.body = .init(
            commentId: commentId,
            distinguished: distinguished
        )
    }
}
