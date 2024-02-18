//
//  ModeratorListView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-15.
//

import Dependencies
import Foundation
import SwiftUI

struct ModeratorListView: View {
    @Dependency(\.siteInformation) var siteInformation
    
    let community: CommunityModel
    let navigationEnabled: Bool
    
    init(community: CommunityModel, navigationEnabled: Bool = true) {
        self.community = community
        self.navigationEnabled = navigationEnabled
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let moderators = community.moderators {
                ForEach(moderators, id: \.id) { user in
                    UserListRow(user, complications: [.date], communityContext: community, navigationEnabled: navigationEnabled)
                    Divider()
                }
            }
            
            if community.isModerator(siteInformation.userId) {
                Text("add mod")
            }
        }
    }
}
