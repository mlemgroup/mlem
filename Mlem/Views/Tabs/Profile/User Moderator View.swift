//
//  User Moderator View.swift
//  Mlem
//
//  Created by Jake Shirley on 6/30/23.
//

import SwiftUI

/*
 A view that displays the list of communities a user moderates
 */
struct UserModeratorView: View {
    @Environment(\.dismiss) private var dismiss
    
    // parameters
    var userDetails: APIPersonView
    var moderatedCommunities: [APICommunityModeratorView]
    
    var body: some View {
        List {
            ForEach(moderatedCommunities) { community in
                CommunityLinkView(community: community.community)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle("Moderator Details")
        .navigationBarColor()
        .navigationBarTitleDisplayMode(.inline)
        .hoistNavigation(dismiss: dismiss)
        .headerProminence(.standard)
        .listStyle(.plain)
    }
}
