//
//  Sidebar.swift
//  Mlem
//
//  Created by David Bureš on 08.05.2023.
//

import SwiftUI

struct CommunitySidebarView: View {

    @State var account: SavedAccount
    @Binding var communityDetails: GetCommunityResponse?
    @Binding var isActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let communityDetails {
                view(for: communityDetails)
            } else {
                ProgressView {
                    Text("Loading details…")
                }
            }
        }
        .navigationTitle("Sidebar")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            isActive = false
        }
    }
    
    @ViewBuilder
    private func view(for communityDetails: GetCommunityResponse) -> some View {
        HStack(alignment: .center, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(communityDetails.communityView.counts.subscribers.formatted())
                Text("subs")
                    .font(.caption)
            }
            .padding(.vertical, 5)
            
            Divider()
            
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(communityDetails.communityView.counts.posts.formatted())
                Text("posts")
                    .font(.caption)
            }
            .padding(.vertical, 5)
            
            Divider()
            
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(communityDetails.online.formatted())
                Text("online")
                    .font(.caption)
            }
            .padding(.vertical, 5)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        
        Divider()
        
        List
        {
            Section("Description")
            {
                if let communityDescription = communityDetails
                    .communityView
                    .community
                    .description
                {
                    MarkdownView(text: communityDescription)
                }
                else
                {
                    Text("Community has no description")
                        .foregroundColor(.secondary)
                }
            }

            NavigationLink {
                List {
                    ForEach(communityDetails.moderators) { moderatorView in
                        UserProfileLink(account: account, user: moderatorView.moderator)
                    }
                }
                .navigationTitle("Moderators")
                .navigationBarTitleDisplayMode(.inline)
            } label: {
                Text("Moderators")
            }
        }
    }
}
