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
}

internal enum RatingFailure: Error
{
    case failedToPostScore, receivedInvalidResponse
}

@MainActor
func ratePost(post: Post, operation: ScoringOperation, account: SavedAccount, postTracker: PostTracker) async throws -> Void
{
    do
    {
        let postRatingResponse: String = try await sendCommand(maintainOpenConnection: false, instanceAddress: account.instanceLink, command: """
        {"op": "CreatePostLike", "data": {"auth": "\(account.accessToken)", "post_id": \(post.id), "score": \(operation.rawValue)}}
        """)
        
        if !postRatingResponse.contains("\"error\"")
        {
            
            print("Successfully scored")
            print(postRatingResponse)
            
            let modifiedPostIndex: Int = postTracker.posts.firstIndex(where: { $0.id == post.id })!
            
            if operation == .upvote
            {
                postTracker.posts[modifiedPostIndex].myVote = .upvoted
                postTracker.posts[modifiedPostIndex].score = postTracker.posts[modifiedPostIndex].score + 1
                postTracker.posts[modifiedPostIndex].name = "DEBUG"
            }
            else
            {
                postTracker.posts[modifiedPostIndex].myVote = .downvoted
                postTracker.posts[modifiedPostIndex].score = postTracker.posts[modifiedPostIndex].score - 1
            }
            
            print(postTracker.posts)
        }
        else
        {
            print("Received bad response from the server: \(postRatingResponse)")
            throw RatingFailure.receivedInvalidResponse
        }
    }
    catch let ratingOperationError
    {
        print("Failed while trying to score: \(ratingOperationError)")
        throw RatingFailure.failedToPostScore
    }
}

func rateComment(comment: Comment, operation: ScoringOperation, accout: SavedAccount) async throws -> Void
{ /// Returns the post, so I will have to do the replacing/processing outside the function
    
}
