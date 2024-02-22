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
            .init(name: "person_id", value: personId.map(String.init)),
            .init(name: "username", value: username),
            .init(name: "sort", value: sort?.rawValue),
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init)),
            .init(name: "community_id", value: communityId.map(String.init)),
            .init(name: "saved_only", value: savedOnly.map(String.init))
        ]
    }
}
