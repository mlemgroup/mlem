//
//  GetCommentsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct GetCommentsRequest: APIGetRequest {
    typealias Response = APIGetCommentsResponse

    let path = "/comment/list"
    let queryItems: [URLQueryItem]

    init(
        type_: APIListingType?,
        sort: APICommentSortType?,
        maxDepth: Int?,
        page: Int?,
        limit: Int?,
        communityId: Int?,
        communityName: String?,
        postId: Int?,
        parentId: Int?,
        savedOnly: Bool?,
        likedOnly: Bool?,
        dislikedOnly: Bool?
    ) {
        var request: APIGetComments = .init(
            type_: type_,
            sort: sort,
            max_depth: maxDepth,
            page: page,
            limit: limit,
            community_id: communityId,
            community_name: communityName,
            post_id: postId,
            parent_id: parentId,
            saved_only: savedOnly,
            liked_only: likedOnly,
            disliked_only: dislikedOnly
        )
        self.queryItems = request.toQueryItems()
    }
}
