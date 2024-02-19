//
//  ResolveObjectRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct ResolveObjectRequest: APIGetRequest {
    typealias Response = APIResolveObjectResponse

    let path = "/resolve_object"
    let queryItems: [URLQueryItem]

    init(
        // swiftlint:disable:next identifier_name
        q: String
    ) {
        self.queryItems = [
            .init(name: "q", value: "\(q)")
        ]
    }
}
