//
//  DeletePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct DeletePostRequest: APIPostRequest {
    typealias Body = APIDeletePost
    typealias Response = APIPostResponse

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
