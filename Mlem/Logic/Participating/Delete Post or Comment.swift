//
//  Delete Post or Comment.swift
//  Mlem
//
//  Created by Jake Shirley on 6/26/23.
//

import Foundation

enum DeletionFailiure: Error {
    case failedToDelete
}

@MainActor
func deletePost(
    postId: Int,
    account: SavedAccount,
    postTracker: PostTracker,
    appState: AppState
) async throws -> APIPostView {
    do {
        let request = DeletePostRequest(
            account: account,
            postId: postId,
            deleted: true
        )
        
        let response = try await APIClient().perform(request: request)
        postTracker.update(with: response.postView)
        AppConstants.hapticManager.notificationOccurred(.success)
        return response.postView
    } catch {
        AppConstants.hapticManager.notificationOccurred(.error)
        throw DeletionFailiure.failedToDelete
    }
}

@MainActor
func deleteComment(
    comment: APICommentView,
    account: SavedAccount,
    commentTracker: CommentTracker,
    appState: AppState
) async throws -> HierarchicalComment? {
    do {
        let request = DeleteCommentRequest(
            account: account,
            commentId: comment.id
        )
        
        let response = try await APIClient().perform(request: request)
        let updatedComment = commentTracker.comments.update(with: response.commentView)
        AppConstants.hapticManager.notificationOccurred(.success)
        return updatedComment
    } catch {
        AppConstants.hapticManager.notificationOccurred(.error)
        print("Failed to delete comment: \(error)")
        throw DeletionFailiure.failedToDelete
    }
}
