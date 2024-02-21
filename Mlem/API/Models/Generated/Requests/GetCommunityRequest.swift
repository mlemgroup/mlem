//
//  GetCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetCommunityRequest: ApiGetRequest {
    typealias Response = ApiGetCommunityResponse

    let path = "/community"
    let queryItems: [URLQueryItem]

    init(
        id: Int?,
        name: String?
    ) {
        self.queryItems = [
            .init(name: "id", value: "\(id)"),
            .init(name: "name", value: "\(name)")
        ]
    }
}
