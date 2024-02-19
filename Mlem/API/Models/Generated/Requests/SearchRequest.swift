//
//  SearchRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct SearchRequest: APIGetRequest {
    typealias Response = APISearchResponse

    let path = "/search"
    let queryItems: [URLQueryItem]

    init(
        // swiftlint:disable:next identifier_name
        q: String,
        communityId: Int?,
        communityName: String?,
        creatorId: Int?,
        type_: APISearchType?,
        sort: APISortType?,
        listingType: APIListingType?,
        page: Int?,
        limit: Int?
    ) {
        self.queryItems = [
            .init(name: "q", value: "\(q)"),
            .init(name: "community_id", value: "\(communityId)"),
            .init(name: "community_name", value: "\(communityName)"),
            .init(name: "creator_id", value: "\(creatorId)"),
            .init(name: "type_", value: "\(type_)"),
            .init(name: "sort", value: "\(sort)"),
            .init(name: "listing_type", value: "\(listingType)"),
            .init(name: "page", value: "\(page)"),
            .init(name: "limit", value: "\(limit)")
        ]
    }
}
