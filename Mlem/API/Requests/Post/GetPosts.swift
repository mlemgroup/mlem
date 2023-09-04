//
//  GetPosts.swift
//  Mlem
//
//  Created by Nicholas Lawson on 07/06/2023.
//

import Foundation

// lemmy_api_common::post::GetPosts
struct GetPostsRequest: APIGetRequest {
    typealias Response = GetPostsResponse

    let instanceURL: URL
    let path = "post/list"
    let queryItems: [URLQueryItem]

    init(
        account: SavedAccount, // TODO: needs to move to a session based call...
        communityId: Int?,
        page: Int,
        sort: PostSortType?,
        type: FeedType,
        limit: Int? = nil,
        savedOnly: Bool? = nil,
        communityName: String? = nil
    ) {
        self.instanceURL = account.instanceLink
        self.queryItems = [
            .init(name: "auth", value: account.accessToken),
            .init(name: "page", value: "\(page)"),
            .init(name: "type_", value: type.rawValue),
            .init(name: "sort", value: sort.map(\.rawValue)),
            .init(name: "community_id", value: communityId.map(String.init)),
            .init(name: "community_name", value: communityName),
            .init(name: "limit", value: limit.map(String.init)),
            .init(name: "saved_only", value: savedOnly.map(String.init))
        ]
    }
    
    init(
        session: APISession,
        communityId: Int?,
        page: Int,
        sort: PostSortType?,
        type: FeedType,
        limit: Int? = nil,
        savedOnly: Bool? = nil,
        communityName: String? = nil
    ) {
        self.instanceURL = session.URL
        self.queryItems = [
            .init(name: "auth", value: session.token),
            .init(name: "page", value: "\(page)"),
            .init(name: "type_", value: type.rawValue),
            .init(name: "sort", value: sort.map(\.rawValue)),
            .init(name: "community_id", value: communityId.map(String.init)),
            .init(name: "community_name", value: communityName),
            .init(name: "limit", value: limit.map(String.init)),
            .init(name: "saved_only", value: savedOnly.map(String.init))
        ]
    }
}

// lemmy_api_common::post::GetPostsResponse
struct GetPostsResponse: Decodable {
    let posts: [APIPostView]
}

// MARK: - FeedTrackerItemProviding

extension GetPostsResponse: FeedTrackerItemProviding {
    var items: [APIPostView] { posts }
}
