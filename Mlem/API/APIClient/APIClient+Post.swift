//
//  NewAPIClient+Post.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

extension APIClient {
    // swiftlint:disable:next function_parameter_count
    func getPosts(
        communityId: Int,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        savedOnly: Bool
    ) async throws -> GetPostsResponse {
        let request = GetPostsRequest(
            communityId: communityId,
            page: page,
            cursor: cursor,
            sort: sort,
            type: .all,
            limit: limit,
            savedOnly: savedOnly
        )
        return try await perform(request: request)
    }
    
    // swiftlint:disable:next function_parameter_count
    func getPosts(
        feedType: APIListingType,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        savedOnly: Bool
    ) async throws -> GetPostsResponse {
        let request = GetPostsRequest(
            communityId: nil,
            page: page,
            cursor: cursor,
            sort: sort,
            type: feedType,
            limit: limit,
            savedOnly: savedOnly
        )
        return try await perform(request: request)
    }
    
    func voteOnPost(id: Int, score: ScoringOperation) async throws -> PostResponse {
        let request = CreatePostLikeRequest(postId: id, score: score)
        return try await perform(request: request)
    }
    
    func savePost(id: Int, shouldSave: Bool) async throws -> PostResponse {
        let request = SavePostRequest(postId: id, save: shouldSave)
        return try await perform(request: request)
    }
}
