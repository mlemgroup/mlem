//
//  GetReportCountRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

struct GetReportCountRequest: APIGetRequest {
    typealias Response = APIGetReportCountResponse

    let instanceURL: URL
    let path = "user/report_count"
    let queryItems: [URLQueryItem]

    init(
        session: APISession,
        communityId: Int?
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.queryItems = try [
            .init(name: "community_id", value: communityId.map(String.init)),
            .init(name: "auth", value: session.token)
        ]
    }
}

// GetReportCountResponse.ts
struct APIGetReportCountResponse: Decodable {
    let communityId: Int?
    let commentReports: Int
    let postReports: Int
    let privateMessageReports: Int?
}
