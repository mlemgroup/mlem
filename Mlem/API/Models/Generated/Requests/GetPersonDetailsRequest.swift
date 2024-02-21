//
//  GetPersonDetailsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetPersonDetailsRequest: ApiGetRequest {
    typealias Response = ApiGetPersonDetailsResponse

    let path = "/user"
    let queryItems: [URLQueryItem]

    init(
        personId: Int?,
        username: String?,
        sort: ApiSortType?,
        page: Int?,
        limit: Int?,
        communityId: Int?,
        savedOnly: Bool?
    ) {
        self.queryItems = [
            .init(name: "person_id", value: "\(personId)"),
            .init(name: "username", value: "\(username)"),
            .init(name: "sort", value: "\(sort)"),
            .init(name: "page", value: "\(page)"),
            .init(name: "limit", value: "\(limit)"),
            .init(name: "community_id", value: "\(communityId)"),
            .init(name: "saved_only", value: "\(savedOnly)")
        ]
    }
}
