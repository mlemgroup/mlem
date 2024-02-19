//
//  GetPersonDetailsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct GetPersonDetailsRequest: APIGetRequest {
    typealias Response = APIGetPersonDetailsResponse

    let path = "/user"
    let queryItems: [URLQueryItem]

    init(
        personId: Int,
        username: String,
        sort: APISortType,
        page: Int,
        limit: Int,
        communityId: Int,
        savedOnly: Bool
    ) {
        var request: APIGetPersonDetails = .init(
            person_id: personId,
            username: username,
            sort: sort,
            page: page,
            limit: limit,
            community_id: communityId,
            saved_only: savedOnly
        )
        self.queryItems = request.toQueryItems()
    }
}
