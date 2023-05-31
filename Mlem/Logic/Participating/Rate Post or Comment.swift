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
func ratePost(post: Post, operation: ScoringOperation, account: SavedAccount, postTracker: PostTracker) async throws -> Void
{
    do
    {
        async let postRatingResponse: String = try sendCommand(maintainOpenConnection: false, instanceAddress: account.instanceLink, command: """
        {"op": "CreatePostLike", "data": {"auth": "\(account.accessToken)", "post_id": \(post.id), "score": \(operation.rawValue)}}
        """)
        
        let modifiedPostIndex: Int = postTracker.posts.firstIndex(where: { $0.id == post.id })!
        
        if operation == .upvote
        {
            print("Old upvotes: \(postTracker.posts[modifiedPostIndex].upvotes)")
            
            postTracker.posts[modifiedPostIndex].myVote = .upvoted
            postTracker.posts[modifiedPostIndex].upvotes += 1
            
            print("New upvotes: \(postTracker.posts[modifiedPostIndex].upvotes)")
        }
        else if operation == .downvote
        {
            postTracker.posts[modifiedPostIndex].myVote = .downvoted
            postTracker.posts[modifiedPostIndex].downvotes += 1
        }
        else if operation == .resetVote
        {
            if postTracker.posts[modifiedPostIndex].myVote == .upvoted
            { /// If the post was previously upvoted, remove an upvote from the score
                postTracker.posts[modifiedPostIndex].upvotes -= 1
            }
            else if postTracker.posts[modifiedPostIndex].myVote == .downvoted
            { /// If the post was previously downvotes, remove a downvote from the score
                postTracker.posts[modifiedPostIndex].downvotes -= 1
            }
            
            postTracker.posts[modifiedPostIndex].myVote = .none /// Finally, set the status of my vote to none
        }
        else
        {
            print("This should never happen")
        }
        
        AppConstants.hapticManager.notificationOccurred(.success)
        
        if try await !postRatingResponse.contains("\"error\"")
        {
            print("Sucessfully rated post")
        }
        else
        {
            print("Received bad response from the server: \(try await postRatingResponse)")
            
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

func rateComment(comment: Comment, operation: ScoringOperation, accout: SavedAccount) async throws -> Void
{ 
    
}
