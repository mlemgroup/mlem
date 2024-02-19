//
//  PurgePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct PurgePostRequest: APIPostRequest {
    typealias Body = APIPurgePost
    typealias Response = APISuccessResponse

    let path = "/admin/purge/post"
    let body: Body?

    init(
        postId: Int,
        reason: String
    ) {
        self.body = .init(
            post_id: postId,
            reason: reason
        )
    }
}
