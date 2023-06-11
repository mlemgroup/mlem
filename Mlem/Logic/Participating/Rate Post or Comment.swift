//
//  Rate Post or Comment.swift
//  Mlem
//
//  Created by David Bureš on 23.05.2023.
//

import Foundation

enum ScoringOperation: Int, Decodable {
    case upvote = 1
    case downvote = -1
    case resetVote = 0
}

enum RatingFailure: Error {
    case failedToPostScore
}

@MainActor
func ratePost(
    post: APIPost,
    operation: ScoringOperation,
    account: SavedAccount,
    postTracker: PostTracker,
    appState: AppState
) async throws {
    do {
        
        let request = CreatePostLikeRequest(
            account: account,
            postId: post.id,
            score: operation
        )
        
        let response = try await APIClient().perform(request: request)
        
        guard let indexToReplace = postTracker.posts.firstIndex(where: { $0.post.id == post.id }) else {
            // shouldn't happen, but safer than force unwrapping
            return
        }
        
        postTracker.posts[indexToReplace] = response.postView
        AppConstants.hapticManager.notificationOccurred(.success)
    } catch {
        AppConstants.hapticManager.notificationOccurred(.error)
        throw RatingFailure.failedToPostScore
    }
}

@MainActor
func rateComment(
    comment: APICommentView,
    operation: ScoringOperation,
    account: SavedAccount,
    commentTracker: CommentTracker,
    appState: AppState
) async throws -> HierarchicalComment? {
    do {
        let request = CreateCommentLikeRequest(
            account: account,
            commentId: comment.id,
            score: operation
        )
        
        let response = try await APIClient().perform(request: request)
        let updatedComment = commentTracker.comments.update(with: response.commentView)
        AppConstants.hapticManager.notificationOccurred(.success)
        return updatedComment
    } catch let ratingOperationError {
        AppConstants.hapticManager.notificationOccurred(.error)
        print("Failed while trying to score: \(ratingOperationError)")
        throw RatingFailure.failedToPostScore
    }
}
