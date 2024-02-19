//
//  GetRepliesRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct GetRepliesRequest: APIGetRequest {
    typealias Response = APIGetRepliesResponse

    let path = "/user/replies"
    let queryItems: [URLQueryItem]

    init(
        sort: APICommentSortType,
        page: Int,
        limit: Int,
        unreadOnly: Bool
    ) {
        var request: APIGetReplies = .init(
            sort: sort,
            page: page,
            limit: limit,
            unread_only: unreadOnly
        )
        self.queryItems = request.toQueryItems()
    }
}
