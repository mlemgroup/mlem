//
//  GetReportCountRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetReportCountRequest: APIGetRequest {
    typealias Response = APIGetReportCountResponse

    let path = "/user/report_count"
    let queryItems: [URLQueryItem]

    init(
        communityId: Int?
    ) {
        self.queryItems = [
            .init(name: "community_id", value: "\(communityId)")
        ]
    }
}
