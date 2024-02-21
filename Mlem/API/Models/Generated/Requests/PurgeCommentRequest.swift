//
//  PurgeCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct PurgeCommentRequest: ApiPostRequest {
    typealias Body = ApiPurgeComment
    typealias Response = ApiSuccessResponse

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
