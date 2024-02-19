//
//  DeletePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

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
            post_id: postId,
            deleted: deleted
        )
    }
}
