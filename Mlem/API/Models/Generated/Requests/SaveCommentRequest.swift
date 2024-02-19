//
//  SaveCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

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
            commentId: commentId,
            save: save
        )
    }
}
