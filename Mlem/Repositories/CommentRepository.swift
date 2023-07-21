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
    @Dependency(\.hapticManager) private var hapticManager
    
    func comment(with id: Int) async throws -> HierarchicalComment {
        do {
            let response = try await apiClient.loadComment(id: id)
            hapticManager.success()
            return .init(comment: response.commentView, children: [])
        } catch {
            hapticManager.error()
            throw error
        }
    }
    
    func comments(for postId: Int) async throws -> [HierarchicalComment] {
        do {
            let response = try await apiClient.loadComments(for: postId)
            hapticManager.success()
            return response.hierarchicalRepresentation
        } catch {
            hapticManager.error()
            throw error
        }
    }
    
    func voteOnComment(id: Int, vote: ScoringOperation) async throws -> APICommentView {
        do {
            let response = try await apiClient.applyCommentScore(id: id, score: vote.rawValue)
            hapticManager.gentleSuccess()
            return response.commentView
        } catch {
            hapticManager.error()
            throw error
        }
    }
    
    func voteOnCommentReply(_ reply: APICommentReplyView, vote: ScoringOperation) async throws -> APICommentReplyView {
        // no haptics here as we defer to the `voteOnComment` method which will produce them if necessary
        do {
            let updatedCommentView = try await voteOnComment(id: reply.comment.id, vote: vote)
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
        } catch {
            throw error
        }
    }
    
    func voteOnPersonMention(_ mention: APIPersonMentionView, vote: ScoringOperation) async throws -> APIPersonMentionView {
        // no haptics here as we defer to the `voteOnComment` method which will produce them if necessary
        do {
            let updatedCommentView = try await voteOnComment(id: mention.comment.id, vote: vote)
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
        } catch {
            throw error
        }

    }
    
    @discardableResult
    func postComment(
        content: String,
        languageId: Int? = nil,
        parentId: Int? = nil,
        postId: Int
    ) async throws -> HierarchicalComment {
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
            hapticManager.error()
            throw error
        }
    }
    
    func editComment(
        id: Int,
        content: String? = nil,
        distinguished: Bool? = nil,
        languageId: Int? = nil,
        formId: String? = nil
    ) async throws -> CommentResponse {
        do {
            let response = try await apiClient.editComment(
                id: id,
                content: content,
                distinguished: distinguished,
                languageId: languageId,
                formId: formId
            )
            
            hapticManager.success()
            return response
        } catch {
            hapticManager.error()
            throw error
        }
    }
    
    func deleteComment(id: Int, shouldDelete: Bool) async throws -> HierarchicalComment {
        do {
            let response = try await apiClient.deleteComment(id: id, deleted: shouldDelete)
            hapticManager.destructiveSuccess()
            return .init(comment: response.commentView, children: [])
        } catch {
            hapticManager.error()
            throw error
        }
    }
    
    func saveComment(id: Int, shouldSave: Bool) async throws -> HierarchicalComment {
        do {
            let response = try await apiClient.saveComment(id: id, shouldSave: shouldSave)
            hapticManager.gentleSuccess()
            return .init(comment: response.commentView, children: [])
        } catch {
            hapticManager.error()
            throw error
        }
    }
    
    @discardableResult
    func reportComment(id: Int, reason: String) async throws -> APICommentReportView {
        do {
            let response = try await apiClient.reportComment(id: id, reason: reason)
            hapticManager.violentSuccess()
            return response.commentReportView
        } catch {
            hapticManager.error()
            throw error
        }
    }
}
