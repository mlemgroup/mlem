//
//  ListPostReportsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct ListPostReportsRequest: APIGetRequest {
    typealias Response = APIListPostReportsResponse

    let path = "/post/report/list"
    let queryItems: [URLQueryItem]

    init(
        page: Int?,
        limit: Int?,
        unresolvedOnly: Bool?,
        communityId: Int?
    ) {
        var request: APIListPostReports = .init(
            page: page,
            limit: limit,
            unresolved_only: unresolvedOnly,
            community_id: communityId
        )
        self.queryItems = request.toQueryItems()
    }
}
