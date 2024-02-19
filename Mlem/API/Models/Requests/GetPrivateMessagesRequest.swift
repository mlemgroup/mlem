//
//  GetPrivateMessagesRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct GetPrivateMessagesRequest: APIGetRequest {
    typealias Response = APIPrivateMessagesResponse

    let path = "/private_message/list"
    let queryItems: [URLQueryItem]

    init(
        unreadOnly: Bool,
        page: Int,
        limit: Int,
        creatorId: Int
    ) {
        var request: APIGetPrivateMessages = .init(
            unread_only: unreadOnly,
            page: page,
            limit: limit,
            creator_id: creatorId
        )
        self.queryItems = request.toQueryItems()
    }
}
