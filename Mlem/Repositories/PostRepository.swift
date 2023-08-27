//
//  PostRepository.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-31.
//

import Dependencies
import Foundation

class PostRepository {
    @Dependency(\.apiClient) private var apiClient
    
    func loadPage(
        communityId: Int?,
        page: Int,
        sort: PostSortType?,
        type: FeedType,
        limit: Int? = nil,
        savedOnly: Bool? = nil,
        communityName: String? = nil
    ) async throws -> [PostModel] {
        return try await apiClient.loadPosts(
            communityId: communityId,
            page: page,
            sort: sort,
            type: type,
            limit: limit,
            savedOnly: savedOnly,
            communityName: communityName
        )
    }
    
    func markRead(for postId: Int, read: Bool) async throws -> APIPostView {
        return try await apiClient.markPostAsRead(for: postId, read: read).postView
    }
}
