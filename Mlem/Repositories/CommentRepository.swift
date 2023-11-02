//
//  CommentRepository.swift
//  Mlem
//
//  Created by mormaer on 14/07/2023.
//
//

import Dependencies
import Foundation

class CommentRepository {
    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.hapticManager) private var hapticManager
    
    func comment(with id: Int) async throws -> HierarchicalComment {
        do {
            let response = try await apiClient.loadComment(id: id)
            return .init(comment: response.commentView, children: [], parentCollapsed: false, collapsed: false)
        } catch {
            throw error
        }
    }
    
    func comments(for postId: Int) async throws -> [HierarchicalComment] {
        do {
            let response = try await apiClient.loadComments(for: postId)
            return response.hierarchicalRepresentation
        } catch {
            throw error
        }
    }
    
    func voteOnComment(id: Int, vote: ScoringOperation) async throws -> APICommentView {
        do {
            let response = try await apiClient.applyCommentScore(id: id, score: vote.rawValue)
            return response.commentView
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
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

            hapticManager.play(haptic: .heavySuccess, priority: .high)
            return .init(comment: response.commentView, children: [], parentCollapsed: false, collapsed: false)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
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
            
            hapticManager.play(haptic: .heavySuccess, priority: .high)
            return response
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            throw error
        }
    }
    
    func deleteComment(id: Int, shouldDelete: Bool) async throws -> HierarchicalComment {
        do {
            let response = try await apiClient.deleteComment(id: id, deleted: shouldDelete)
            hapticManager.play(haptic: .destructiveSuccess, priority: .high)
            return .init(comment: response.commentView, children: [], parentCollapsed: false, collapsed: false)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            throw error
        }
    }
    
    func saveComment(id: Int, shouldSave: Bool) async throws -> HierarchicalComment {
        do {
            let response = try await apiClient.saveComment(id: id, shouldSave: shouldSave)
            return .init(comment: response.commentView, children: [], parentCollapsed: false, collapsed: false)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            throw error
        }
    }
    
    @discardableResult
    func reportComment(id: Int, reason: String) async throws -> APICommentReportView {
        do {
            let response = try await apiClient.reportComment(id: id, reason: reason)
            hapticManager.play(haptic: .violentSuccess, priority: .high)
            return response.commentReportView
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            throw error
        }
    }
}
