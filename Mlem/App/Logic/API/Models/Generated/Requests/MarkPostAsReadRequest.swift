//
//  MarkPostAsReadRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct MarkPostAsReadRequest: ApiPostRequest {
    typealias Body = ApiMarkPostAsRead
    typealias Response = ApiSuccessResponse

    let path = "/post/mark_as_read"
    let body: Body?

    init(
        postId: Int?,
        postIds: [Int]?,
        read: Bool
    ) {
        self.body = .init(
            postId: postId,
            postIds: postIds,
            read: read
        )
    }
}
