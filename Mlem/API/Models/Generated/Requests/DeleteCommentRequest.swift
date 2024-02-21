//
//  DeleteCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct DeleteCommentRequest: ApiPostRequest {
    typealias Body = ApiDeleteComment
    typealias Response = ApiCommentResponse

    let path = "/comment/delete"
    let body: Body?

    init(
        commentId: Int,
        deleted: Bool
    ) {
        self.body = .init(
            commentId: commentId,
            deleted: deleted
        )
    }
}
