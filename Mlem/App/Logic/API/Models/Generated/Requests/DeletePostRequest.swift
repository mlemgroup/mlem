//
//  DeletePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct DeletePostRequest: ApiPostRequest {
    typealias Body = ApiDeletePost
    typealias Response = ApiPostResponse

    let path = "/post/delete"
    let body: Body?

    init(
        postId: Int,
        deleted: Bool
    ) {
        self.body = .init(
            postId: postId,
            deleted: deleted
        )
    }
}
