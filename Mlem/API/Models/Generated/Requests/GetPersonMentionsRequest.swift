//
//  GetPersonMentionsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetPersonMentionsRequest: ApiGetRequest {
    typealias Response = ApiGetPersonMentionsResponse

    let path = "/user/mention"
    let queryItems: [URLQueryItem]

    init(
        sort: ApiCommentSortType?,
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
