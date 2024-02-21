//
//  EditCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct EditCommentRequest: ApiPutRequest {
    typealias Body = ApiEditComment
    typealias Response = ApiCommentResponse

    let path = "/comment"
    let body: Body?

    init(
        commentId: Int,
        content: String?,
        languageId: Int?,
        formId: String?
    ) {
        self.body = .init(
            commentId: commentId,
            content: content,
            languageId: languageId,
            formId: formId
        )
    }
}
