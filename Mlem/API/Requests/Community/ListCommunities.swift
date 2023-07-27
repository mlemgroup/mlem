//
//  ListCommunities.swift
//  Mlem
//
//  Created by Jonathan de Jong on 12.06.2023.
//

import Foundation

// lemmy_api_common::community::ListCommunities
struct ListCommunitiesRequest: APIGetRequest {

    typealias Response = ListCommunityResponse

    let instanceURL: URL
    let path = "community/list"
    let queryItems: [URLQueryItem]

    init(
        session: APISession,

        sort: String?,
        page: Int?,
        limit: Int?,

        type: String
    ) {
        self.instanceURL = session.URL
        self.queryItems = [
            .init(name: "sort", value: sort),
            .init(name: "limit", value: limit?.description),
            .init(name: "page", value: page?.description),
            .init(name: "type_", value: type),

            .init(name: "auth", value: session.token)
        ]
    }
}

// lemmy_api_common::community::ListCommunitiesResponse
struct ListCommunityResponse: Decodable {
    var communities: [APICommunityView]
}
