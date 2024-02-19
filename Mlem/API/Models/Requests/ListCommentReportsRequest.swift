//
//  ListCommentReportsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct ListCommentReportsRequest: APIGetRequest {
    typealias Response = APIListCommentReportsResponse

    let path = "/comment/report/list"
    let queryItems: [URLQueryItem]

    init(
        page: Int,
        limit: Int,
        unresolvedOnly: Bool,
        communityId: Int
    ) {
        var request: APIListCommentReports = .init(
            page: page,
            limit: limit,
            unresolved_only: unresolvedOnly,
            community_id: communityId
        )
        self.queryItems = request.toQueryItems()
    }
}
