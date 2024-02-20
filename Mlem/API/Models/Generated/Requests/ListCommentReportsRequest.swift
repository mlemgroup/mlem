//
//  ListCommentReportsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct ListCommentReportsRequest: APIGetRequest {
    typealias Response = APIListCommentReportsResponse

    let path = "/comment/report/list"
    let queryItems: [URLQueryItem]

    init(
        page: Int?,
        limit: Int?,
        unresolvedOnly: Bool?,
        communityId: Int?
    ) {
        self.queryItems = [
            .init(name: "page", value: "\(page)"),
            .init(name: "limit", value: "\(limit)"),
            .init(name: "unresolved_only", value: "\(unresolvedOnly)"),
            .init(name: "community_id", value: "\(communityId)")
        ]
    }
}
