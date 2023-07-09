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
        throw error
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
    } catch {
        AppConstants.hapticManager.notificationOccurred(.error)
        throw error
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
        
        commentReplyTracker.update(with: newCommentReplyView)
    } catch {
        AppConstants.hapticManager.notificationOccurred(.error)
        throw error
    }
}

@MainActor
func ratePersonMention(
    personMention: APIPersonMentionView,
    operation: ScoringOperation,
    account: SavedAccount,
    mentionsTracker: FeedTracker<APIPersonMentionView>,
    appState: AppState
) async throws {
    do {
        let request = CreateCommentLikeRequest(
            account: account,
            commentId: personMention.comment.id,
            score: operation
        )

        AppConstants.hapticManager.notificationOccurred(.success)
        let response = try await APIClient().perform(request: request)
  
        let newPersonMentionView = APIPersonMentionView(personMention: personMention.personMention,
                                                        comment: response.commentView.comment,
                                                        creator: personMention.creator,
                                                        post: response.commentView.post,
                                                        community: response.commentView.community,
                                                        recipient: personMention.recipient,
                                                        counts: response.commentView.counts,
                                                        creatorBannedFromCommunity: response.commentView.creatorBannedFromCommunity,
                                                        subscribed: response.commentView.subscribed,
                                                        saved: response.commentView.saved,
                                                        creatorBlocked: response.commentView.creatorBlocked,
                                                        myVote: response.commentView.myVote)

        mentionsTracker.update(with: newPersonMentionView)
    } catch {
        AppConstants.hapticManager.notificationOccurred(.error)
        throw error
    }
}
