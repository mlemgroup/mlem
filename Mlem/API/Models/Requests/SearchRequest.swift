//
//  SearchRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct SearchRequest: APIGetRequest {
    typealias Response = APISearchResponse

    let path = "/search"
    let queryItems: [URLQueryItem]

    init(
        q: String,
        communityId: Int,
        communityName: String,
        creatorId: Int,
        type_: APISearchType,
        sort: APISortType,
        listingType: APIListingType,
        page: Int,
        limit: Int
    ) {
        var request: APISearch = .init(
            q: q,
            community_id: communityId,
            community_name: communityName,
            creator_id: creatorId,
            type_: type_,
            sort: sort,
            listing_type: listingType,
            page: page,
            limit: limit
        )
        self.queryItems = request.toQueryItems()
    }
}
