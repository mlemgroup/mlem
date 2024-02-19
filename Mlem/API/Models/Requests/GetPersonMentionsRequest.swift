//
//  GetPersonMentionsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct GetPersonMentionsRequest: APIGetRequest {
    typealias Response = APIGetPersonMentionsResponse

    let path = "/user/mention"
    let queryItems: [URLQueryItem]

    init(
        sort: APICommentSortType?,
        page: Int?,
        limit: Int?,
        unreadOnly: Bool?
    ) {
        var request: APIGetPersonMentions = .init(
            sort: sort,
            page: page,
            limit: limit,
            unread_only: unreadOnly
        )
        self.queryItems = request.toQueryItems()
    }
}
