//
//  ListCommentReportsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

struct ListCommentReportsRequest: APIGetRequest {
    typealias Response = APIListCommentReportsResponse
    
    let instanceURL: URL
    let path = "comment/report/list"
    let queryItems: [URLQueryItem]
    
    init(
        session: APISession,
        page: Int?,
        limit: Int?,
        unresolvedOnly: Bool?,
        communityId: Int?
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.queryItems = try [
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init)),
            .init(name: "unresolved_only", value: unresolvedOnly.map(String.init)),
            .init(name: "community_id", value: communityId.map(String.init)),
            .init(name: "auth", value: session.token)
        ]
    }
}

struct APIListCommentReportsResponse: Decodable {
    let commentReports: [APICommentReportView]
}
