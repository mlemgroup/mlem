//
//  GetCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetCommunityRequest: APIGetRequest {
    typealias Response = APIGetCommunityResponse

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
