//
//  GetPrivateMessages.swift
//  Mlem
//
//  Created by Jake Shirley on 6/25/23.
//

import Foundation

struct GetPrivateMessagesRequest: APIGetRequest {
    typealias Response = GetPrivateMessagesResponse

    let instanceURL: URL
    let path = "private_message/list"
    let queryItems: [URLQueryItem]

    // lemmy_api_common::person::GetPersonDetails
    init(
        session: APISession,
        page: Int?,
        limit: Int?,
        unreadOnly: Bool
        // TODO: 0.19 support add creator_id? field
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.queryItems = try [
            .init(name: "auth", value: session.token),
            .init(name: "page", value: page?.description),
            .init(name: "limit", value: limit?.description),
            .init(name: "unread_only", value: String(unreadOnly))
        ]
    }
}

struct GetPrivateMessagesResponse: Decodable {
    let privateMessages: [APIPrivateMessageView]
}

// MARK: - FeedTrackerItemProviding

extension GetPrivateMessagesResponse: FeedTrackerItemProviding {
    var items: [APIPrivateMessageView] { privateMessages }
}
