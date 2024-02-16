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
        case let .moderators(community):
            moderators(for: community)
        default:
            Text("TODO: implement")
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
