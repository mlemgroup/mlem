//
//  ListCommunitiesRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct ListCommunitiesRequest: APIGetRequest {
    typealias Response = APIListCommunitiesResponse

    let path = "/community/list"
    let queryItems: [URLQueryItem]

    init(
        type_: APIListingType,
        sort: APISortType,
        showNsfw: Bool,
        page: Int,
        limit: Int
    ) {
        var request: APIListCommunities = .init(
            type_: type_,
            sort: sort,
            show_nsfw: showNsfw,
            page: page,
            limit: limit
        )
        self.queryItems = request.toQueryItems()
    }
}
