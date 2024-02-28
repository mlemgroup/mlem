//
//  APIClient+Post.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-26.
//

import Foundation

extension APIClient {
    // swiftlint:disable function_parameter_count
    func loadPosts(
        communityId: Int?,
        page: Int,
        cursor: String?,
        sort: PostSortType?,
        type: APIListingType,
        limit: Int?,
        savedOnly: Bool?,
        communityName: String?
    ) async throws -> GetPostsResponse {
        let request = try GetPostsRequest(
            session: session,
            communityId: communityId,
            page: page,
            cursor: cursor,
            sort: sort,
            type: type,
            limit: limit,
            savedOnly: savedOnly,
            communityName: communityName
        )
        
        return try await perform(request: request)
    }

    // swiftlint:enable function_parameter_count
    
    func markPostAsRead(for postId: Int, read: Bool) async throws -> SuccessResponse {
        let request = try MarkPostReadRequest(session: session, postId: postId, read: read)
        // TODO: 0.18 deprecation simply return result of perform
        let compatibilityResponse = try await perform(request: request)
        return SuccessResponse(from: compatibilityResponse)
    }
    
    func markPostsAsRead(for postIds: [Int], read: Bool) async throws -> SuccessResponse {
        let request = try MarkPostReadRequest(session: session, postIds: postIds, read: read)
        // TODO: 0.18 deprecation simply return result of perform
        let compatibilityResponse = try await perform(request: request)
        return SuccessResponse(from: compatibilityResponse)
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
    
    // swiftlint:disable function_parameter_count
    func editPost(
        postId: Int,
        name: String?,
        url: String?,
        body: String?,
        nsfw: Bool?,
        languageId: Int?
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

    // swiftlint:enable function_parameter_count
    
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
    
    func featurePost(id: Int, shouldFeature: Bool, featureType: ApiPostFeatureType) async throws -> APIPostView {
        let request = try FeaturePostRequest(
            session: session,
            postId: id,
            featured: shouldFeature,
            featureType: featureType
        )
        return try await perform(request: request).postView
    }
    
    func lockPost(id: Int, shouldLock: Bool) async throws -> APIPostView {
        let request = try LockPostRequest(session: session, postId: id, locked: shouldLock)
        return try await perform(request: request).postView
    }
    
    func removePost(id: Int, shouldRemove: Bool, reason: String?) async throws -> PostModel {
        let request = try RemovePostRequest(session: session, postId: id, removed: shouldRemove, reason: reason)
        let response = try await perform(request: request).postView
        return PostModel(from: response)
    }
}
