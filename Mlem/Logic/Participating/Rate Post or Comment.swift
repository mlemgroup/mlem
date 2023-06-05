//
//  Rate Post or Comment.swift
//  Mlem
//
//  Created by David Bureš on 23.05.2023.
//

import Foundation

internal enum ScoringOperation: Int
{
    case upvote = 1
    case downvote = -1
    case resetVote = 0
}

internal enum RatingFailure: Error
{
    case failedToPostScore, receivedInvalidResponse
}

// Abandon all hope, ye who has to read this function
@MainActor
func ratePost(post: Post, operation: ScoringOperation, account: SavedAccount, postTracker: PostTracker, appState: AppState) async throws
{
    do
    {
        async let postRatingResponse: String = try sendPostCommand(appState: appState, account: account, endpoint: "post/like", arguments: [
            "post_id": post.id,
            "score": operation.rawValue
        ])

        let modifiedPostIndex: Int = postTracker.posts.firstIndex(where: { $0.id == post.id })!

        var updatedPost: Post = post
        
        switch post.myVote
        {
        case .upvoted:
            switch operation
            {
            case .upvote:
                    updatedPost.myVote = .none
                    updatedPost.score -= 1
            case .resetVote:
                    updatedPost.myVote = .none
                    updatedPost.score -= 1
            case .downvote:
                    updatedPost.myVote = .downvoted
                    updatedPost.score -= 2
            }
        case .downvoted:
            switch operation
            {
            case .upvote:
                    updatedPost.myVote = .upvoted
                    updatedPost.score += 2
            case .resetVote:
                    updatedPost.myVote = .none
                    updatedPost.score += 1
            case .downvote:
                    updatedPost.myVote = .none
                    updatedPost.score += 1
            }
        case .none:
            switch operation
            {
            case .upvote:
                    updatedPost.myVote = .upvoted
                    updatedPost.score += 1
            case .resetVote:
                    updatedPost.myVote = .none
                    updatedPost.score += 0
            case .downvote:
                    updatedPost.myVote = .downvoted
                    updatedPost.score -= 1
            }
        }
        
        postTracker.posts[modifiedPostIndex] = updatedPost

        AppConstants.hapticManager.notificationOccurred(.success)

        if try await !postRatingResponse.contains("\"error\"")
        {
            print("Sucessfully rated post")
        }
        else
        {
            try print("Received bad response from the server: \(await postRatingResponse)")

            AppConstants.hapticManager.notificationOccurred(.error)

            /// Revert the score in case there was an error
            if operation == .upvote
            {
                postTracker.posts[modifiedPostIndex].myVote = .none
                postTracker.posts[modifiedPostIndex].upvotes -= 1
            }
            else if operation == .downvote
            {
                postTracker.posts[modifiedPostIndex].myVote = .none
                postTracker.posts[modifiedPostIndex].downvotes -= 1
            }
            else if operation == .resetVote
            {
                if postTracker.posts[modifiedPostIndex].myVote == .upvoted
                { /// If the post was previously upvoted, add an upvote to the score
                    postTracker.posts[modifiedPostIndex].upvotes += 1
                }
                else if postTracker.posts[modifiedPostIndex].myVote == .downvoted
                { /// If the post was previously downvoted, add a downvote to the score
                    postTracker.posts[modifiedPostIndex].downvotes += 1
                }

                postTracker.posts[modifiedPostIndex].myVote = .none /// Finally, set the status of my vote to none
            }
            else
            {
                print("This should never happen")
            }

            throw RatingFailure.receivedInvalidResponse
        }
    }
    catch let ratingOperationError
    {
        AppConstants.hapticManager.notificationOccurred(.error)
        print("Failed while trying to score: \(ratingOperationError)")
        throw RatingFailure.failedToPostScore
    }
}

@MainActor
func rateComment(comment: Comment, operation: ScoringOperation, account: SavedAccount, commentTracker: CommentTracker, appState: AppState) async throws
{
    do
    {
        async let commentRatingReponse: String = try await sendPostCommand(appState: appState, account: account, endpoint: "comment/like", arguments: [
            "comment_id": comment.id,
            "score": operation.rawValue
        ])

        var updatedComment: Comment = comment

        switch comment.myVote
        {
        case .upvoted:
            switch operation
            {
            case .upvote:
                updatedComment.myVote = .none
                updatedComment.score -= 1
            case .resetVote:
                updatedComment.myVote = .none
                updatedComment.score -= 1
            case .downvote:
                updatedComment.myVote = .downvoted
                updatedComment.score -= 2
            }

        case .downvoted:
            switch operation
            {
            case .upvote:
                updatedComment.myVote = .upvoted
                updatedComment.score += 2
            case .resetVote:
                updatedComment.myVote = .none
                updatedComment.score += 1
            case .downvote:
                updatedComment.myVote = .none
                updatedComment.score += 1
            }
        case .none:
            switch operation
            {
            case .upvote:
                updatedComment.myVote = .upvoted
                updatedComment.score += 1
            case .resetVote:
                updatedComment.myVote = .none
                updatedComment.score += 0
            case .downvote:
                updatedComment.myVote = .downvoted
                updatedComment.score -= 1
            }
        }

        // updatedComment.content = "OH HEY"

        commentTracker.comments = commentTracker.comments.map { $0.replaceReply(updatedComment) }

        AppConstants.hapticManager.notificationOccurred(.success)

        if try await !commentRatingReponse.contains("\"error\"")
        {
            print("Successfully rated comment")
        }
    }
    catch let ratingOperationError
    {
        AppConstants.hapticManager.notificationOccurred(.error)
        print("Failed while trying to score: \(ratingOperationError)")
        throw RatingFailure.failedToPostScore
    }
}
