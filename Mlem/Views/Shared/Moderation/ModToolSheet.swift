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
        case let .communityBan(user, community, bannedFromCommunity, shouldBan, postTracker):
            BanUserView(
                user: user,
                communityContext: community,
                bannedFromCommunity: bannedFromCommunity,
                shouldBan: shouldBan,
                postTracker: postTracker
            )
        case let .addMod(user, community):
            AddModView(community: community, user: user)
        case let .instanceBan(user, shouldBan):
                user: user,
                communityContext: nil,
                shouldBan: shouldBan,
                postTracker: nil
            ) // TODO: add post tracker support
        case let .removePost(post, shouldRemove):
            RemovePostView(post: post, shouldRemove: shouldRemove)
        }
    }
}
