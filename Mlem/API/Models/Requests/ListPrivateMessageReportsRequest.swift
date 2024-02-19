//
//  ListPrivateMessageReportsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct ListPrivateMessageReportsRequest: APIGetRequest {
    typealias Response = APIListPrivateMessageReportsResponse

    let path = "/private_message/report/list"
    let queryItems: [URLQueryItem]

    init(
        page: Int?,
        limit: Int?,
        unresolvedOnly: Bool?
    ) {
        var request: APIListPrivateMessageReports = .init(
            page: page,
            limit: limit,
            unresolved_only: unresolvedOnly
        )
        self.queryItems = request.toQueryItems()
    }
}
