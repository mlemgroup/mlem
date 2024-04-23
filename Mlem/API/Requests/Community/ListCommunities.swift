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
    ) throws {
        self.instanceURL = try session.instanceUrl
        var queryItems: [URLQueryItem] = [
            .init(name: "sort", value: sort ?? "Old"), // provide explicit sort if not provided to ensure consistent pagination
            .init(name: "limit", value: limit?.description),
            .init(name: "page", value: page?.description),
            .init(name: "type_", value: type)
        ]
        
        if let token = try? session.token {
            queryItems.append(
                .init(name: "auth", value: token)
            )
        }
        
        self.queryItems = queryItems
    }
}

// lemmy_api_common::community::ListCommunitiesResponse
struct ListCommunityResponse: Decodable {
    var communities: [APICommunityView]
}
