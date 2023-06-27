//
//  Save Comment.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-21.
//

import Foundation

@MainActor
func sendSaveCommentRequest(account: SavedAccount,
                            commentId: Int,
                            save: Bool,
                            commentTracker: CommentTracker) async throws {
    do {
        let request = SaveCommentRequest(account: account, commentId: commentId, save: save)

        AppConstants.hapticManager.notificationOccurred(.success)

        let response = try await APIClient().perform(request: request)

        commentTracker.comments.update(with: response.commentView)
    } catch {
        print(error)
        AppConstants.hapticManager.notificationOccurred(.error)
        throw SavingFailure.failedToSaveComment
    }
}
