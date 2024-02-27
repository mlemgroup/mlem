//
//  ModToolSheet.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-14.
//

import Foundation
import SwiftUI

// TOOLS TO ADD
//
// inline
// - remove post (POST /post/remove)
// - lock post (POST /post/lock)
// - feature post (POST /post/feature)
// - distinguish comment (POST /comment/distinguish)
// - ban user (POST /community/ban_user)
//
// tools
// - edit community (PUT /community)
// - delete community (DELETE /community or POST /community/remove?)
// - moderators
//   - add mod (POST /community/mod)
//   - transfer community to another moderator (POST /community/transfer)
// - moderate user
//   - get report count (GET /user/report_count)
//   - get post history on your community (person details + filter)
//   - ban user (POST /community/ban_user)
//
// inbox
// - get post reports (GET /post/report/list)
// - resolve post report (PUT /post/report/resolve)
// - get comment reports (GET /comment/report/list)
// - resolve comment report (PUT /comment/report/resolve)
//
// investigate further
// - get banned users(?) (GET /user/banned)

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
        }
    }
    
    @ViewBuilder
    func moderators(for community: CommunityModel) -> some View {
        VStack(spacing: 0) {
            Divider()
            
            ModeratorListView(community: community, navigationEnabled: false)
            
            Spacer()
        }
        .navigationTitle("Moderators")
    }
}
