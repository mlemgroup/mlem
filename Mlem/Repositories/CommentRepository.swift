// 
//  CommentRepository.swift
//  Mlem
//
//  Created by mormaer on 14/07/2023.
//  
//

import Foundation
import Dependencies

class CommentRepository {
    
    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.errorHandler) private var errorHandler
    @Dependency(\.hapticManager) private var hapticManager
    
    func comment(with id: Int) async -> HierarchicalComment? {
        do {
            let response = try await apiClient.loadComment(id: id)
            return .init(comment: response.commentView, children: [])
        } catch {
            errorHandler.handle(
                .init(
                    title: "Failed to load comment",
                    message: "Please try again",
                    underlyingError: error
                )
            )
            
            return nil
        }
    }
    
    func comments(for postId: Int) async -> [HierarchicalComment] {
        do {
            return try await apiClient
                .loadComments(for: postId)
                .hierarchicalRepresentation
        } catch {
            errorHandler.handle(
                .init(
                    title: "Failed to load comments",
                    message: "Please refresh to try again",
                    underlyingError: error
                )
            )
            
            return []
        }
    }
    
    func voteOnComment(id: Int, vote: ScoringOperation) async -> APICommentView? {
        do {
            let response = try await apiClient.applyCommentScore(id: id, score: vote.rawValue)
            hapticManager.gentleSuccess()
            return response.commentView
        } catch {
            hapticManager.error()
            errorHandler.handle(
                .init(underlyingError: error)
            )
            
            return nil
        }
    }
    
    func voteOnCommentReply(_ reply: APICommentReplyView, vote: ScoringOperation) async -> APICommentReplyView? {
        if let updatedCommentView = await voteOnComment(id: reply.comment.id, vote: vote) {
            return .init(
                commentReply: reply.commentReply,
                comment: updatedCommentView.comment,
                creator: updatedCommentView.creator,
                post: updatedCommentView.post,
                community: updatedCommentView.community,
                recipient: reply.recipient,
                counts: updatedCommentView.counts,
                creatorBannedFromCommunity: updatedCommentView.creatorBannedFromCommunity,
                subscribed: updatedCommentView.subscribed,
                saved: updatedCommentView.saved,
                creatorBlocked: updatedCommentView.creatorBlocked,
                myVote: updatedCommentView.myVote
            )
        }
        
        return nil
    }
    
    func voteOnPersonMention(_ mention: APIPersonMentionView, vote: ScoringOperation) async -> APIPersonMentionView? {
        if let updatedCommentView = await voteOnComment(id: mention.comment.id, vote: vote) {
            return .init(
                personMention: mention.personMention,
                comment: updatedCommentView.comment,
                creator: mention.creator,
                post: updatedCommentView.post,
                community: updatedCommentView.community,
                recipient: mention.recipient,
                counts: updatedCommentView.counts,
                creatorBannedFromCommunity: updatedCommentView.creatorBannedFromCommunity,
                subscribed: updatedCommentView.subscribed,
                saved: updatedCommentView.saved,
                creatorBlocked: updatedCommentView.creatorBlocked,
                myVote: updatedCommentView.myVote
            )
        }
        
        return nil
    }
    
    @discardableResult
    func postComment(
        content: String,
        languageId: Int? = nil,
        parentId: Int? = nil,
        postId: Int
    ) async -> HierarchicalComment? {
        do {
            let response = try await apiClient
                .createComment(
                    content: content,
                    languageId: languageId,
                    parentId: parentId,
                    postId: postId
                )
            
            hapticManager.success()
            return .init(comment: response.commentView, children: [])
        } catch {
            errorHandler.handle(
                .init(
                    title: "Failed to post comment",
                    message: "Please try again",
                    underlyingError: error
                )
            )
            
            return nil
        }
    }
    
    func editComment(
        id: Int,
        content: String? = nil,
        distinguished: Bool? = nil,
        languageId: Int? = nil,
        formId: String? = nil
    ) async -> CommentResponse? {
        do {
            return try await apiClient.editComment(
                id: id,
                content: content,
                distinguished: distinguished,
                languageId: languageId,
                formId: formId
            )
        } catch {
            errorHandler.handle(
                .init(
                    title: "Failed to edit comment",
                    message: "Please try again",
                    underlyingError: error
                )
            )
            
            return nil
        }
    }
    
    func deleteComment(id: Int, shouldDelete: Bool) async -> HierarchicalComment? {
        do {
            let response = try await apiClient.deleteComment(id: id, deleted: shouldDelete)
            hapticManager.destructiveSuccess()
            return .init(comment: response.commentView, children: [])
        } catch {
            hapticManager.error()
            let verb = shouldDelete ? "delete" : "restore"
            errorHandler.handle(
                .init(
                    title: "Failed to \(verb) comment",
                    message: "Please try again",
                    underlyingError: error
                )
            )
            
            return nil
        }
    }
    
    func saveComment(id: Int, shouldSave: Bool) async -> HierarchicalComment? {
        do {
            let response = try await apiClient.saveComment(id: id, shouldSave: shouldSave)
            hapticManager.gentleSuccess()
            return .init(comment: response.commentView, children: [])
        } catch {
            hapticManager.error()
            errorHandler.handle(
                .init(underlyingError: error)
            )
            
            return nil
        }
    }
    
    @discardableResult
    func reportComment(id: Int, reason: String) async -> APICommentReportView? {
        do {
            let response = try await apiClient.reportComment(id: id, reason: reason)
            hapticManager.violentSuccess()
            return response.commentReportView
        } catch {
            hapticManager.error()
            errorHandler.handle(
                .init(underlyingError: error)
            )
            
            return nil
        }
    }
}
