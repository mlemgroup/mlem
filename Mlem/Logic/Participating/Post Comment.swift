//
//  Post Comment.swift
//  Mlem
//
//  Created by David Bureš on 20.05.2023.
//

import Foundation
import SwiftUI

internal enum CommentPostingFailure: Error
{
    case couldNotPost, receivedInvalidServerResponse, coundNotParseUpdatedComments
}

@MainActor
func postComment(to post: Post, commentContents: String, commentTracker: CommentTracker, account: SavedAccount, appState: AppState) async throws
{
    do
    {
        let commentPostingCommandResult: String = try await sendPostCommand(appState: appState, account: account, endpoint: "comment", arguments: [
            "content": commentContents,
            "post_id": post.id
        ])

        print("Successfuly posted comment: \(commentPostingCommandResult)")

        if !commentPostingCommandResult.contains("\"error\"")
        {
            do
            {
                let postedComment: Comment = try await parseComments(commentResponse: commentPostingCommandResult, instanceLink: account.instanceLink).first!
                
                withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 1, blendDuration: 0.4))
                {
                    commentTracker.comments.prepend(postedComment)
                }
            }
            catch let commentParsingError
            {
                
                appState.alertType = .customError(title: "Couldn't read updated comment", message: "Refresh comments to see your new comment.")
                
                print("Failed while parsing updated comment: \(commentParsingError)")
            }
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

@MainActor
func postComment(to comment: Comment, post: Post, commentContents: String, commentTracker: CommentTracker, account: SavedAccount, appState: AppState) async throws
{
    do
    {
        let commentPostingCommandResult: String = try await sendPostCommand(appState: appState, account: account, endpoint: "comment", arguments: [
            "content": commentContents,
            "parent_id": comment.id,
            "post_id": post.id
        ])
        
        print("Successfuly posted comment: \(commentPostingCommandResult)")
        
        if !commentPostingCommandResult.contains("\"error\"")
        {
            do
            {
                let newComment: Comment = try await parseReply(replyResponse: commentPostingCommandResult, instanceLink: account.instanceLink)
                
                print(newComment)
                
                withAnimation(Animation.interactiveSpring(response: 0.5, dampingFraction: 1, blendDuration: 0.5))
                {
                    commentTracker.comments = commentTracker.comments.map({ $0.insertReply(newComment) })
                    
                    print("New comment tracker state: \(commentTracker.comments)")
                }
            }
            catch let commentParsingError
            {
                
                appState.alertType = .customError(title: "Couldn't read updated comment", message: "Refresh comments to see your new comment.")
                
                print("Failed while parsing updated comment: \(commentParsingError)")
            }
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
