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
            .init(name: "sort", value: sort?.rawValue),
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init)),
            .init(name: "unread_only", value: unreadOnly.map(String.init))
        ]
    }
}
