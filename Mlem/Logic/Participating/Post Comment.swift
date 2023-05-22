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
    case couldNotPost, receivedInvalidServerResponse
}

func postComment(to post: Post, commentContents: String, commentTracker: CommentTracker, account: SavedAccount) async throws
{
    do
    {
        let commentPostingCommandResult: String = try await sendCommand(maintainOpenConnection: false, instanceAddress: account.instanceLink, command: """
        {"op": "CreateComment", "data": {"auth": "\(account.accessToken)", "content": "\(commentContents)", "post_id": \(post.id)}}
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
