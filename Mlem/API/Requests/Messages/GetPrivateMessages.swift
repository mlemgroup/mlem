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
    @available(*, deprecated, message: "Migrate to PostModel")
    init(
        account: SavedAccount, // TODO: move to session based call, auth required.
        page: Int? = nil,
        limit: Int? = nil,
        unreadOnly: Bool = false
    ) {
        self.instanceURL = account.instanceLink
        self.queryItems = [
            .init(name: "auth", value: account.accessToken),
            .init(name: "page", value: page?.description),
            .init(name: "limit", value: limit?.description),
            .init(name: "unread_only", value: String(unreadOnly))
        ]
    }
    
    init(
        session: APISession,
        page: Int? = nil,
        limit: Int? = nil,
        unreadOnly: Bool = false
    ) {
        self.instanceURL = session.URL
        self.queryItems = [
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
