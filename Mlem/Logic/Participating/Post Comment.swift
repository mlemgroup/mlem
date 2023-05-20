//
//  Post Comment.swift
//  Mlem
//
//  Created by David Bureš on 20.05.2023.
//

import Foundation

internal enum CommentPostingFailure: Error
{
    case couldNotPost, receivedInvalidServerResponse
}

func postComment(to post: Post, commentContents: String, commentTracker: CommentTracker, account: SavedAccount) async throws -> Void
{
    do
    {
        let commentPostingCommandResult: String = try await sendCommand(maintainOpenConnection: false, instanceAddress: account.instanceLink, command: """
        {"op": "CreateComment", "data": {"auth": "\(account.accessToken)", "content": "\(commentContents)", "post_id": \(post.id)}}
        """)
        
        print("Successfuly posted comment: \(commentPostingCommandResult)")
        
        if !commentPostingCommandResult.contains("error")
        {
            await commentTracker.comments.prepend(try! parseComments(commentResponse: commentPostingCommandResult, instanceLink: account.instanceLink).first!)
        }
        else
        {
            print("Received error from server")
            
            throw CommentPostingFailure.receivedInvalidServerResponse
        }
    }
    catch let commentPostingError
    {
        print("Failed while posting comment: \(commentPostingError)")
        
        throw CommentPostingFailure.couldNotPost
    }
}
