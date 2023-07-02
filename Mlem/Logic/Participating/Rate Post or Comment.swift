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
    postId: Int,
    operation: ScoringOperation,
    account: SavedAccount,
    postTracker: PostTracker,
    appState: AppState
) async throws -> APIPostView {
    do {
        let request = CreatePostLikeRequest(
            account: account,
            postId: postId,
            score: operation
        )

        AppConstants.hapticManager.notificationOccurred(.success)
        let response = try await APIClient().perform(request: request)
        postTracker.update(with: response.postView)
        return response.postView
    } catch {
        AppConstants.hapticManager.notificationOccurred(.error)
        throw RatingFailure.failedToPostScore
    }
}

@MainActor
func rateComment(
    commentId: Int,
    operation: ScoringOperation,
    account: SavedAccount,
    commentTracker: CommentTracker,
    appState: AppState
) async throws -> HierarchicalComment? {
    do {
        let request = CreateCommentLikeRequest(
            account: account,
            commentId: commentId,
            score: operation
        )

        AppConstants.hapticManager.notificationOccurred(.success)
        let response = try await APIClient().perform(request: request)
        let updatedComment = commentTracker.comments.update(with: response.commentView)
        return updatedComment
    } catch let ratingOperationError {
        AppConstants.hapticManager.notificationOccurred(.error)
        print("Failed while trying to score: \(ratingOperationError)")
        throw RatingFailure.failedToPostScore
    }
}

@MainActor
func rateCommentReply(
    commentReply: APICommentReplyView,
    operation: ScoringOperation,
    account: SavedAccount,
    commentReplyTracker: FeedTracker<APICommentReplyView>,
    appState: AppState
) async throws {
    do {
        let request = CreateCommentLikeRequest(
            account: account,
            commentId: commentReply.comment.id,
            score: operation
        )

        AppConstants.hapticManager.notificationOccurred(.success)
        let response = try await APIClient().perform(request: request)
        
        let newCommentReplyView = APICommentReplyView(commentReply: commentReply.commentReply,
                                                      comment: response.commentView.comment,
                                                      creator: response.commentView.creator,
                                                      post: response.commentView.post,
                                                      community: response.commentView.community,
                                                      recipient: commentReply.recipient,
                                                      counts: response.commentView.counts,
                                                      creatorBannedFromCommunity: response.commentView.creatorBannedFromCommunity,
                                                      subscribed: response.commentView.subscribed,
                                                      saved: response.commentView.saved,
                                                      creatorBlocked: response.commentView.creatorBlocked,
                                                      myVote: response.commentView.myVote)
        
        let updatedComment = commentReplyTracker.update(with: newCommentReplyView)
    } catch let ratingOperationError {
        AppConstants.hapticManager.notificationOccurred(.error)
        print("Failed while trying to score: \(ratingOperationError)")
        throw RatingFailure.failedToPostScore
    }
}
