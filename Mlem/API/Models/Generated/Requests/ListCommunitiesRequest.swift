//
//  ListCommunitiesRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct ListCommunitiesRequest: ApiGetRequest {
    typealias Response = ApiListCommunitiesResponse

    let path = "/community/list"
    let queryItems: [URLQueryItem]

    init(
        type_: ApiListingType?,
        sort: ApiSortType?,
        showNsfw: Bool?,
        page: Int?,
        limit: Int?
    ) {
        self.queryItems = [
            .init(name: "type_", value: "\(type_)"),
            .init(name: "sort", value: "\(sort)"),
            .init(name: "show_nsfw", value: "\(showNsfw)"),
            .init(name: "page", value: "\(page)"),
            .init(name: "limit", value: "\(limit)")
        ]
    }
}
