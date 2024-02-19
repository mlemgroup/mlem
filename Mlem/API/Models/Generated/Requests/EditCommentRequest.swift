//
//  EditCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct EditCommentRequest: APIPutRequest {
    typealias Body = APIEditComment
    typealias Response = APICommentResponse

    let path = "/comment"
    let body: Body?

    init(
        commentId: Int,
        content: String?,
        languageId: Int?
    ) {
        self.body = .init(
            commentId: commentId,
            content: content,
            languageId: languageId
        )
    }
}
