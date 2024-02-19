//
//  MarkPostAsReadRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct MarkPostAsReadRequest: APIPostRequest {
    typealias Body = APIMarkPostAsRead
    typealias Response = APISuccessResponse

    let path = "/post/mark_as_read"
    let body: Body?

    init(
        postId: Int,
        postIds: [Int],
        read: Bool
    ) {
        self.body = .init(
            post_id: postId,
            post_ids: postIds,
            read: read
        )
    }
}
