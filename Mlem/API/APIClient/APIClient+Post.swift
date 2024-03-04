//
//  NewApiClient+Post.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

extension ApiClient {
    // swiftlint:disable:next function_parameter_count
    func getPosts(
        communityId: Int,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        savedOnly: Bool
    ) async throws -> ApiGetPostsResponse {
        let request = try GetPostsRequest(
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
        feedType: ApiListingType,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        savedOnly: Bool
    ) async throws -> ApiGetPostsResponse {
        let request = try GetPostsRequest(
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
    
    func getPost(id: Int) async throws -> ApiGetPostResponse {
        let request = GetPostRequest(id: id, commentId: nil)
        return try await perform(request: request)
    }
    
    func getPost(actorId: URL) async throws -> ApiPostView? {
        let urlString = actorId.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let request = ResolveObjectRequest(q: urlString ?? actorId.absoluteString)
        let response = try await perform(request: request)
        return response.post
    }
    
    func voteOnPost(id: Int, score: ScoringOperation) async throws -> ApiPostResponse {
        let request = LikePostRequest(postId: id, score: score.rawValue)
        return try await perform(request: request)
    }
    
    func savePost(id: Int, shouldSave: Bool) async throws -> ApiPostResponse {
        let request = SavePostRequest(postId: id, save: shouldSave)
        return try await perform(request: request)
    }
}
