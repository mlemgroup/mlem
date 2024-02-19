//
//  ResolveObjectRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct ResolveObjectRequest: APIGetRequest {
    typealias Response = APIResolveObjectResponse

    let path = "/resolve_object"
    let queryItems: [URLQueryItem]

    init(
        q: String
    ) {
        var request: APIResolveObject = .init(
            q: q
        )
        self.queryItems = request.toQueryItems()
    }
}
