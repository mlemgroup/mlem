//
//  ListPrivateMessageReportsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

struct ListPrivateMessageReportsRequest: APIGetRequest {
    typealias Response = APIListPrivateMessageReportsResponse
    
    let instanceURL: URL
    let path = "private_message/report/list"
    let queryItems: [URLQueryItem]
    
    init(
        session: APISession,
        page: Int?,
        limit: Int?,
        unresolvedOnly: Bool?
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.queryItems = try [
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init)),
            .init(name: "unresolved_only", value: unresolvedOnly.map(String.init)),
            .init(name: "auth", value: session.token)
        ]
    }
}

struct APIListPrivateMessageReportsResponse: Decodable {
    let privateMessageReports: [APIPrivateMessageReportView]
}
