//
//  ListPrivateMessageReportsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct ListPrivateMessageReportsRequest: APIGetRequest {
    typealias Response = APIListPrivateMessageReportsResponse

    let path = "/private_message/report/list"
    let queryItems: [URLQueryItem]

    init(
        page: Int?,
        limit: Int?,
        unresolvedOnly: Bool?
    ) {
        self.queryItems = [
            .init(name: "page", value: "\(page)"),
            .init(name: "limit", value: "\(limit)"),
            .init(name: "unresolved_only", value: "\(unresolvedOnly)")
        ]
    }
}
