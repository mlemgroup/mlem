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
        account: SavedAccount,
        postId: Int,
        maxDepth: Int = 15,
        type: FeedType = .all,
        // TODO replace this with proper comment sort type, current one has .active, which is not in API
        sort: String? = nil,
        page: Int? = nil,
        limit: Int? = nil,
        communityId: Int? = nil,
        communityName: String? = nil,
        parentId: Int? = nil,
        savedOnly: Bool? = nil
    ) {
        self.instanceURL = account.instanceLink
        self.queryItems = [
            .init(name: "auth", value: account.accessToken),
            .init(name: "post_id", value: "\(postId)"),
            .init(name: "max_depth", value: "\(maxDepth)"),
            .init(name: "type_", value: type.rawValue),
            .init(name: "sort", value: sort),
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
