//
//  CreateCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct CreateCommentRequest: APIPostRequest {
    typealias Body = APICreateComment
    typealias Response = APICommentResponse

    let path = "/comment"
    let body: Body?

    init(
        content: String,
        postId: Int,
        parentId: Int?,
        languageId: Int?
    ) {
        self.body = .init(
            content: content,
            post_id: postId,
            parent_id: parentId,
            language_id: languageId
        )
    }
}
