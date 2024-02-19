//
//  RemovePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct RemovePostRequest: APIPostRequest {
    typealias Body = APIRemovePost
    typealias Response = APIPostResponse

    let path = "/post/remove"
    let body: Body?

    init(
        postId: Int,
        removed: Bool,
        reason: String?
    ) {
        self.body = .init(
            post_id: postId,
            removed: removed,
            reason: reason
        )
    }
}
