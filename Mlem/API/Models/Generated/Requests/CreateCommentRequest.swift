//
//  CreateCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct CreateCommentRequest: APIPostRequest {
    typealias Body = APICreateComment
    typealias Response = APICommentResponse

    let path = "/comment"
    let body: Body?

    init(
        content: String,
        postId: Int,
        parentId: Int?,
        languageId: Int?,
        formId: String?
    ) {
        self.body = .init(
            content: content,
            postId: postId,
            parentId: parentId,
            languageId: languageId,
            formId: formId
        )
    }
}
