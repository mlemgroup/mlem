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
            comment_id: commentId,
            content: content,
            language_id: languageId
        )
    }
}
