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
            .init(name: "type_", value: type_?.rawValue),
            .init(name: "sort", value: sort?.rawValue),
            .init(name: "show_nsfw", value: showNsfw.map(String.init)),
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init))
        ]
    }
}
