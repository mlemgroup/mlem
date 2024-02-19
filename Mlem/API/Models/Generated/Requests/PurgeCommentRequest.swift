//
//  PurgeCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct PurgeCommentRequest: APIPostRequest {
    typealias Body = APIPurgeComment
    typealias Response = APISuccessResponse

    let path = "/admin/purge/comment"
    let body: Body?

    init(
        commentId: Int,
        reason: String?
    ) {
        self.body = .init(
            commentId: commentId,
            reason: reason
        )
    }
}
