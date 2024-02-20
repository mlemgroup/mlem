//
//  RemovePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

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
            postId: postId,
            removed: removed,
            reason: reason
        )
    }
}
