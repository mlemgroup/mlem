//
//  PurgePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct PurgePostRequest: ApiPostRequest {
    typealias Body = ApiPurgePost
    typealias Response = ApiSuccessResponse

    let path = "/admin/purge/post"
    let body: Body?

    init(
        postId: Int,
        reason: String?
    ) {
        self.body = .init(
            postId: postId,
            reason: reason
        )
    }
}
