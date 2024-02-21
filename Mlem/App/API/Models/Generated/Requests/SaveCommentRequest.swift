//
//  SaveCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct SaveCommentRequest: ApiPutRequest {
    typealias Body = ApiSaveComment
    typealias Response = ApiCommentResponse

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
