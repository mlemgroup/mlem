//
//  GetPersonMentions.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation

struct GetPersonMentionsRequest: APIGetRequest {
    typealias Response = GetPersonMentionsResponse

    let instanceURL: URL
    let path = "user/mention"
    let queryItems: [URLQueryItem]

    // lemmy_api_common::person::GetPersonMentions
    init(
        session: APISession,
        sort: PostSortType? = nil,
        page: Int? = nil,
        limit: Int? = nil,
        unreadOnly: Bool = false
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
struct GetPersonMentionsResponse: Decodable {
    let mentions: [APIPersonMentionView]
}

// MARK: - FeedTrackerItemProviding

extension GetPersonMentionsResponse: FeedTrackerItemProviding {
    var items: [APIPersonMentionView] { mentions }
}
