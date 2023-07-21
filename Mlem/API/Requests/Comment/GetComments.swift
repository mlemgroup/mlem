//
//  GetComments.swift
//  Mlem
//
//  Created by Nicholas Lawson on 08/06/2023.
//

import Foundation

struct GetCommentsRequest: APIGetRequest {

    typealias Response = GetCommentsResponse

    let instanceURL: URL
    let path = "comment/list"
    let queryItems: [URLQueryItem]

    // lemmy_api_common::comment::GetComments
    init(
        session: APISession,
        postId: Int,
        maxDepth: Int,
        type: FeedType,
        sort: CommentSortType?,
        page: Int?,
        limit: Int?,
        communityId: Int?,
        communityName: String?,
        parentId: Int?,
        savedOnly: Bool?
    ) {
        self.instanceURL = session.URL
        self.queryItems = [
            .init(name: "auth", value: session.token),
            .init(name: "post_id", value: "\(postId)"),
            .init(name: "max_depth", value: "\(maxDepth)"),
            .init(name: "type_", value: type.rawValue),
            .init(name: "sort", value: sort?.rawValue.description),
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init)),
            .init(name: "community_id", value: communityId.map(String.init)),
            .init(name: "community_name", value: communityName),
            .init(name: "parent_id", value: parentId.map(String.init)),
            .init(name: "saved_only", value: savedOnly.map(String.init))
        ]

    }
}

// lemmy_api_common::comment::GetCommentsResponse
struct GetCommentsResponse: Decodable {
    let comments: [APICommentView]
}
