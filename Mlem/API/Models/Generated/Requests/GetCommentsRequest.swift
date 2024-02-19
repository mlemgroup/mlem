//
//  GetCommentsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

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
        self.queryItems = [
            .init(name: "type_", value: "\(type_)"),
            .init(name: "sort", value: "\(sort)"),
            .init(name: "max_depth", value: "\(maxDepth)"),
            .init(name: "page", value: "\(page)"),
            .init(name: "limit", value: "\(limit)"),
            .init(name: "community_id", value: "\(communityId)"),
            .init(name: "community_name", value: "\(communityName)"),
            .init(name: "post_id", value: "\(postId)"),
            .init(name: "parent_id", value: "\(parentId)"),
            .init(name: "saved_only", value: "\(savedOnly)"),
            .init(name: "liked_only", value: "\(likedOnly)"),
            .init(name: "disliked_only", value: "\(dislikedOnly)")
        ]
    }
}
