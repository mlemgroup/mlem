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
        case let .instanceBan(user, shouldBan):
            BanUserView(user: user, community: nil, shouldBan: shouldBan, postTracker: nil) // TODO: add
        case let .communityBan(user, community, shouldBan, postTracker):
            BanUserView(user: user, community: community, shouldBan: shouldBan, postTracker: postTracker)
        case .editCommunity:
            Text("Not yet!")
        case let .removePost(post, shouldRemove):
            RemovePostView(post: post, shouldRemove: shouldRemove)
        }
    }
    
}
