//
//  GetPrivateMessagesRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetPrivateMessagesRequest: ApiGetRequest {
    typealias Response = ApiPrivateMessagesResponse

    let path = "/private_message/list"
    let queryItems: [URLQueryItem]

    init(
        unreadOnly: Bool?,
        page: Int?,
        limit: Int?,
        creatorId: Int?
    ) {
        self.queryItems = [
            .init(name: "unread_only", value: unreadOnly.map(String.init)),
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init)),
            .init(name: "creator_id", value: creatorId.map(String.init))
        ]
    }
}
