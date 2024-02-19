//
//  SaveCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct SaveCommentRequest: APIPutRequest {
    typealias Body = APISaveComment
    typealias Response = APICommentResponse

    let path = "/comment/save"
    let body: Body?

    init(
        commentId: Int,
        save: Bool
    ) {
        self.body = .init(
            comment_id: commentId,
            save: save
        )
    }
}
