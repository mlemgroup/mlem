//
//  GetPostsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct GetPostsRequest: APIGetRequest {
    typealias Response = APIGetPostsResponse

    let path = "/post/list"
    let queryItems: [URLQueryItem]

    init(
        type_: APIListingType,
        sort: APISortType,
        page: Int,
        limit: Int,
        communityId: Int,
        communityName: String,
        savedOnly: Bool,
        likedOnly: Bool,
        dislikedOnly: Bool,
        pageCursor: String
    ) {
        var request: APIGetPosts = .init(
            type_: type_,
            sort: sort,
            page: page,
            limit: limit,
            community_id: communityId,
            community_name: communityName,
            saved_only: savedOnly,
            liked_only: likedOnly,
            disliked_only: dislikedOnly,
            page_cursor: pageCursor
        )
        self.queryItems = request.toQueryItems()
    }
}
