//
//  GetPersonUnreadCount.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-26.
//

import Foundation

public struct GetPersonUnreadCount: APIGetRequest {
    typealias Response = APIPersonUnreadCounts

    let path = "user/unread_count"
    let instanceURL: URL
    let queryItems: [URLQueryItem]

    init(session: APISession) throws {
        self.instanceURL = try session.instanceUrl
        
        let queryItems: [URLQueryItem] = try [
            .init(name: "auth", value: session.token)
        ]
        self.queryItems = queryItems
    }
}
