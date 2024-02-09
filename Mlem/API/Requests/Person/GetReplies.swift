//
//  GetReplies.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation

struct GetRepliesRequest: APIGetRequest {
    typealias Response = GetRepliesResponse

    let instanceURL: URL
    let path = "user/replies"
    let queryItems: [URLQueryItem]

    // lemmy_api_common::person::GetPersonMentions
    init(
        session: APISession,
        sort: PostSortType?,
        page: Int?,
        limit: Int?,
        unreadOnly: Bool
    ) throws {
        self.instanceURL = try session.instanceUrl
        
        self.queryItems = try [
            .init(name: "auth", value: session.token),
            .init(name: "sort", value: sort?.rawValue),
            .init(name: "page", value: page?.description),
            .init(name: "limit", value: limit?.description),
            .init(name: "unread_only", value: String(unreadOnly))
        ]
    }
}

// lemmy_api_common::person::GetPersonDetailsResponse
struct GetRepliesResponse: Decodable {
    let replies: [APICommentReplyView]
}
