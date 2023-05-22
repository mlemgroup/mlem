//
//  Post Post.swift
//  Mlem
//
//  Created by David Bureš on 22.05.2023.
//

import Foundation
import SwiftUI

internal enum PostPostingFailure: Error
{
    case couldNotPost, receivedInvalidServerResponse
}

func postPost(to community: Community, postTitle: String, postBody: String, postURL: String, postIsNSFW: Bool, postTracker: PostTracker, account: SavedAccount) async throws
{
    do
    {
        let postPostingCommandResult: String = try await sendCommand(maintainOpenConnection: false, instanceAddress: account.instanceLink, command: """
        {"op": "CreatePost", "data": {"auth": "\(account.accessToken)", "name": "\(postTitle)", "body": "\(postBody)", "url": "\(postURL)", "nsfw": \(postIsNSFW), "community_id": \(community.id)}}
        """)
        print("Successfuly posted post: \(postPostingCommandResult)")

        if !postPostingCommandResult.contains("\"error\"")
        {
            let postedPost: Post = try! await parsePosts(postResponse: postPostingCommandResult, instanceLink: account.instanceLink).first!

            withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 1, blendDuration: 0.4))
            {
                postTracker.posts.prepend(postedPost)
            }
        }
        else
        {
            print("Received error from the server")

            throw PostPostingFailure.receivedInvalidServerResponse
        }
    }
    catch let postPostingError
    {
        print("Failed while posting post: \(postPostingError)")

        throw PostPostingFailure.couldNotPost
    }
}
