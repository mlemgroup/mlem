//
//  GetPrivateMessagesRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetPrivateMessagesRequest: APIGetRequest {
    typealias Response = APIPrivateMessagesResponse

    let path = "/private_message/list"
    let queryItems: [URLQueryItem]

    init(
        unreadOnly: Bool?,
        page: Int?,
        limit: Int?,
        creatorId: Int?
    ) {
        self.queryItems = [
            .init(name: "unread_only", value: "\(unreadOnly)"),
            .init(name: "page", value: "\(page)"),
            .init(name: "limit", value: "\(limit)"),
            .init(name: "creator_id", value: "\(creatorId)")
        ]
    }
}
