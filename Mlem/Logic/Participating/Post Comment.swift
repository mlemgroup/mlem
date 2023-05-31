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

func postComment(to post: Post, commentContents: String, commentTracker: CommentTracker, account: SavedAccount) async throws
{
    do
    {
        let commentPostingCommandResult: String = try await sendCommand(maintainOpenConnection: false, instanceAddress: account.instanceLink, command: """
        {"op": "CreateComment", "data": {"auth": "\(account.accessToken)", "content": \(commentContents.withEscapedCharacters()), "language_id": 37, "post_id": \(post.id)}}
        """)

        print("Successfuly posted comment: \(commentPostingCommandResult)")

        if !commentPostingCommandResult.contains("\"error\"")
        {
            let postedComment: Comment = try! await parseComments(commentResponse: commentPostingCommandResult, instanceLink: account.instanceLink).first!

            withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 1, blendDuration: 0.4))
            {
                commentTracker.comments.prepend(postedComment)
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

func postComment(to comment: Comment, post: Post, commentContents: String, commentTracker: CommentTracker, account: SavedAccount) async throws
{
    do
    {
        let commentPostingCommandResult: String = try await sendCommand(maintainOpenConnection: true, instanceAddress: account.instanceLink, command: """
        {"op": "CreateComment", "data": {"auth": "\(account.accessToken)", "content": \(commentContents.withEscapedCharacters()), "language_id": 37, "parent_id": \(comment.id), "post_id": \(post.id)}}
        """)
        
        print("Successfuly posted comment: \(commentPostingCommandResult)")
        
        if !commentPostingCommandResult.contains("\"error\"")
        {
            let updatedCommentReponse: String = try await sendCommand(maintainOpenConnection: true, instanceAddress: account.instanceLink, command: """
                {"op": "GetComments", "data": { "auth": "\(account.accessToken)", "max_depth": 90, "post_id": \(post.id), "type_": "All" }}
                """)
            
            do
            {
                let parsedUpdatedComments: [Comment] = try! await parseComments(commentResponse: updatedCommentReponse, instanceLink: account.instanceLink)
                
                commentTracker.comments = parsedUpdatedComments
            }
            catch let updatedCommentResponseParsingError
            {
                print("Failed while parsing updated comment response: \(updatedCommentResponseParsingError)")
                
                throw CommentPostingFailure.coundNotParseUpdatedComments
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
