//
//  GetPersonMentionsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

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
        self.queryItems = [
            .init(name: "sort", value: "\(sort)"),
            .init(name: "page", value: "\(page)"),
            .init(name: "limit", value: "\(limit)"),
            .init(name: "unread_only", value: "\(unreadOnly)")
        ]
    }
}
