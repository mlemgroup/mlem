//
//  ModToolSheet.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-14.
//

import Foundation
import SwiftUI

struct ModToolSheet: View {
    let tool: ModTool
    
    var body: some View {
        switch tool {
        case .editCommunity:
            Text("Not yet!")
        case let .banUser(user, community, bannedFromCommunity, shouldBan, postTracker, commentTracker, votesTracker):
            BanUserView(
                user: user,
                communityContext: community,
                bannedFromCommunity: bannedFromCommunity ?? false,
                shouldBan: shouldBan,
                postTracker: postTracker,
                commentTracker: commentTracker,
                votesTracker: votesTracker
            )
        case let .addMod(user, community):
            AddModView(community: community, user: user)
        case let .removePost(post, shouldRemove):
            RemovePostView(post: post, shouldRemove: shouldRemove)
        case let .removeCommunity(community, shouldRemove):
            RemoveCommunityView(community: community, shouldRemove: shouldRemove)
        case let .removeComment(comment, shouldRemove):
            RemoveCommentView(comment: comment, shouldRemove: shouldRemove)
        }
    }
}
