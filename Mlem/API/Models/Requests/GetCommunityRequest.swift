//
//  GetCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct GetCommunityRequest: APIGetRequest {
    typealias Response = APIGetCommunityResponse

    let path = "/community"
    let queryItems: [URLQueryItem]

    init(
        id: Int,
        name: String
    ) {
        var request: APIGetCommunity = .init(
            id: id,
            name: name
        )
        self.queryItems = request.toQueryItems()
    }
}
