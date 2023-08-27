//
//  APIClient+Post.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-26.
//

import Foundation

extension APIClient {
    func loadPosts(
        communityId: Int?,
        page: Int,
        sort: PostSortType?,
        type: FeedType,
        limit: Int? = nil,
        savedOnly: Bool? = nil,
        communityName: String? = nil
    ) async throws -> [PostModel] {
        let request = try GetPostsRequest(
            session: session,
            communityId: communityId,
            page: page,
            sort: sort,
            type: type,
            limit: limit,
            savedOnly: savedOnly,
            communityName: communityName
        )
        
        return try await perform(request: request)
            .posts
            .map { PostModel(from: $0) }
    }
}
