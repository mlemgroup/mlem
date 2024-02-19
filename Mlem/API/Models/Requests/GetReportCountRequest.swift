//
//  GetReportCountRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct GetReportCountRequest: APIGetRequest {
    typealias Response = APIGetReportCountResponse

    let path = "/user/report_count"
    let queryItems: [URLQueryItem]

    init(
        communityId: Int?
    ) {
        var request: APIGetReportCount = .init(
            community_id: communityId
        )
        self.queryItems = request.toQueryItems()
    }
}
