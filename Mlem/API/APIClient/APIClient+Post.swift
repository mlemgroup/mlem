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
    ) async throws -> [APIPostView] {
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
        
        return try await perform(request: request).posts
    }
    
    func markPostAsRead(for postId: Int, read: Bool) async throws -> PostResponse {
        let request = try MarkPostReadRequest(session: session, postId: postId, read: read)
        return try await perform(request: request)
    }
    
    func loadPost(id: Int, commentId: Int? = nil) async throws -> APIPostView {
        let request = try GetPostRequest(session: session, id: id, commentId: commentId)
        return try await perform(request: request).postView
    }
    
    func createPost(
        communityId: Int,
        name: String,
        nsfw: Bool?,
        body: String?,
        url: String?
    ) async throws -> PostResponse {
        let request = try CreatePostRequest(
            session: session,
            communityId: communityId,
            name: name,
            nsfw: nsfw,
            body: body,
            url: url
        )
        
        return try await perform(request: request)
    }
    
    func editPost(
        postId: Int,
        name: String?,
        url: String?,
        body: String?,
        nsfw: Bool?,
        languageId: Int? = nil
    ) async throws -> PostResponse {
        let request = try EditPostRequest(
            session: session,
            postId: postId,
            name: name,
            url: url,
            body: body,
            nsfw: nsfw,
            languageId: languageId
        )
        
        return try await perform(request: request)
    }
    
    func ratePost(id: Int, score: ScoringOperation) async throws -> APIPostView {
        let request = try CreatePostLikeRequest(session: session, postId: id, score: score)
        return try await perform(request: request).postView
    }
    
    func deletePost(id: Int, shouldDelete: Bool) async throws -> APIPostView {
        let request = try DeletePostRequest(session: session, postId: id, deleted: shouldDelete)
        return try await perform(request: request).postView
    }
    
    @discardableResult
    func reportPost(id: Int, reason: String) async throws -> APIPostReportView {
        let request = try CreatePostReportRequest(session: session, postId: id, reason: reason)
        return try await perform(request: request).postReportView
    }
    
    func savePost(id: Int, shouldSave: Bool) async throws -> APIPostView {
        let request = try SavePostRequest(session: session, postId: id, save: shouldSave)
        return try await perform(request: request).postView
    }
}
