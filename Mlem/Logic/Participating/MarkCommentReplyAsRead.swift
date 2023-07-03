//
//  MarkCommentReplyAsRead.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-01.
//

import Foundation

@MainActor
func sendMarkCommentReplyAsReadRequest(
    commentReply: APICommentReplyView,
    read: Bool,
    account: SavedAccount,
    commentReplyTracker: FeedTracker<APICommentReplyView>,
    appState: AppState
) async throws {
    do {
        let request = MarkCommentReplyAsRead(
            account: account,
            commentId: commentReply.id,
            read: read
        )

        AppConstants.hapticManager.notificationOccurred(.success)
        let response = try await APIClient().perform(request: request)
        
        commentReplyTracker.update(with: response.commentReplyView)
    } catch let ratingOperationError {
        AppConstants.hapticManager.notificationOccurred(.error)
        print("Failed while trying to mark read: \(ratingOperationError)")
        throw RatingFailure.failedToPostScore
    }
}
