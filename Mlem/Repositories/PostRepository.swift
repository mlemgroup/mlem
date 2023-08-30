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
    
    func markRead(postId: Int, read: Bool) async throws -> APIPostView {
        return try await apiClient.markPostAsRead(for: postId, read: read).postView
    }
    
    /**
     Rates a given post. Does not care what the current vote state is; sends the given request no matter what (i.e., calling this with operation .upvote on an already upvoted post will not send a .resetVote, but instead send a second idempotent .upvote
     
     - Parameters:
        - postId: id of the post to rate
        - operation: ScoringOperation to apply to the given post id
     - Returns:
        - PostModel representing the new state of the post
     */
    func ratePost(postId: Int, operation: ScoringOperation) async throws -> PostModel {
        let response = try await apiClient.ratePost(id: postId, score: operation)
        return PostModel(from: response)
    }
}
