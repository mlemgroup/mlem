//
//  APIClient+Comment.swift
//  Mlem
//
//  Created by mormaer on 27/07/2023.
//
//

import Foundation

extension APIClient {
    func loadComments(
        for postId: Int,
        maxDepth: Int = 15,
        type: APIListingType = .all,
        sort: CommentSortType? = nil,
        page: Int? = nil,
        limit: Int? = nil,
        communityId: Int? = nil,
        communityName: String? = nil,
        parentId: Int? = nil,
        savedOnly: Bool? = nil
    ) async throws -> [APICommentView] {
        let request = try GetCommentsRequest(
            session: session,
            postId: postId,
            maxDepth: maxDepth,
            type: type,
            sort: sort,
            page: page,
            limit: limit,
            communityId: communityId,
            communityName: communityName,
            parentId: parentId,
            savedOnly: savedOnly
        )
        
        return try await perform(request: request).comments
    }
    
    func loadComment(id: Int) async throws -> CommentResponse {
        let request = try GetCommentRequest(session: session, id: id)
        return try await perform(request: request)
    }
    
    func createComment(
        content: String,
        languageId: Int? = nil,
        parentId: Int? = nil,
        postId: Int
    ) async throws -> CommentResponse {
        let request = try CreateCommentRequest(
            session: session,
            content: content,
            languageId: languageId,
            parentId: parentId,
            postId: postId
        )
        
        return try await perform(request: request)
    }
    
    func applyCommentScore(id: Int, score: Int) async throws -> CommentResponse {
        let request = try CreateCommentLikeRequest(session: session, commentId: id, score: score)
        return try await perform(request: request)
    }
    
    func editComment(
        id: Int,
        content: String? = nil,
        distinguished: Bool? = nil,
        languageId: Int? = nil,
        formId: String? = nil
    ) async throws -> CommentResponse {
        let request = try EditCommentRequest(
            session: session,
            commentId: id,
            content: content,
            distinguished: distinguished,
            languageId: languageId,
            formId: formId
        )
        
        return try await perform(request: request)
    }
    
    func deleteComment(
        id: Int,
        deleted: Bool
    ) async throws -> CommentResponse {
        let request = try DeleteCommentRequest(session: session, commentId: id, deleted: deleted)
        return try await perform(request: request)
    }
    
    func saveComment(id: Int, shouldSave: Bool) async throws -> CommentResponse {
        let request = try SaveCommentRequest(session: session, commentId: id, save: shouldSave)
        return try await perform(request: request)
    }
    
    func reportComment(id: Int, reason: String) async throws -> CreateCommentReportResponse {
        let request = try CreateCommentReportRequest(session: session, commentId: id, reason: reason)
        return try await perform(request: request)
    }
    
    func removeComment(id: Int, shouldRemove: Bool, reason: String?) async throws -> CommentResponse {
        let request = try RemoveCommentRequest(session: session, commentId: id, removed: shouldRemove, reason: reason)
        return try await perform(request: request)
    }
    
    func purgeComment(id: Int, reason: String?) async throws -> SuccessResponse {
        let request = try PurgeCommentRequest(session: session, commentId: id, reason: reason)
        return try await perform(request: request)
    }
    
    func getCommentLikes(
        id: Int,
        page: Int,
        limit: Int?
    ) async throws -> APIListCommentLikesResponse {
        let request = try ListCommentLikesRequest(
            session: session,
            commentId: id,
            page: page,
            limit: limit
        )
        return try await perform(request: request)
    }
}
