//
//  GetPersonMentions.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation

enum GetPersonMentionsRequestError: Error {
    case invalidArguments
    case unableToDetermineInstanceHost
}

struct GetPersonMentionsRequest: APIGetRequest {

    typealias Response = GetPersonMentionsResponse

    let instanceURL: URL
    let path = "user/mention"
    let queryItems: [URLQueryItem]

    // lemmy_api_common::person::GetPersonMentions
    init(
        account: SavedAccount,
        sort: PostSortType? = nil,
        page: Int? = nil,
        limit: Int? = nil,
        unreadOnly: Bool = false
    ) {
        self.instanceURL = account.instanceLink
        
        let queryItems: [URLQueryItem] = [
            .init(name: "auth", value: account.accessToken),
            .init(name: "sort", value: sort?.rawValue),
            .init(name: "page", value: page?.description),
            .init(name: "limit", value: limit?.description),
            .init(name: "unread_only", value: String(unreadOnly))
        ]

        self.queryItems = queryItems
    }
}

// lemmy_api_common::person::GetPersonDetailsResponse
struct GetPersonMentionsResponse: Decodable {
    let mentions: [APIPersonMentionView]
}
