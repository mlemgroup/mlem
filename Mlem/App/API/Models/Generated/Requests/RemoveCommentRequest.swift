//
//  RemoveCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct RemoveCommentRequest: ApiPostRequest {
    typealias Body = ApiRemoveComment
    typealias Response = ApiCommentResponse

    let path = "/comment/remove"
    let body: Body?

    init(
        commentId: Int,
        removed: Bool,
        reason: String?
    ) {
        self.body = .init(
            commentId: commentId,
            removed: removed,
            reason: reason
        )
    }
}
