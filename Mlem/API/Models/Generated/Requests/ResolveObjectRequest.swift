//
//  ResolveObjectRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct ResolveObjectRequest: ApiGetRequest {
    typealias Response = ApiResolveObjectResponse

    let path = "/resolve_object"
    let queryItems: [URLQueryItem]

    init(
        // swiftlint:disable:next identifier_name
        q: String
    ) {
        self.queryItems = [
            .init(name: "q", value: q)
        ]
    }
}
