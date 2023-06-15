//
//  ResolveObject.swift
//  Mlem
//
//  Created by Jonathan de Jong on 14.06.2023.
//

import Foundation

// lemmy_api_common::site::ResolveObject
struct ResolveObjectRequest: APIGetRequest {

    typealias Response = ResolveObjectResponse

    let instanceURL: URL
    let path = "resolve_object"
    let queryItems: [URLQueryItem]

    init(
        account: SavedAccount,

        query: String
    ) {
        self.instanceURL = account.instanceLink
        self.queryItems = [
            .init(name: "q", value: query),

            .init(name: "auth", value: account.accessToken),
        ]
    }
}

// lemmy_api_common::site::ResolveObjectResponse
struct ResolveObjectResponse: Decodable {
    let comment: APICommentView?
    let post: APIPostView?
    let community: APICommunityView?
    let person: APIPersonView?
}
