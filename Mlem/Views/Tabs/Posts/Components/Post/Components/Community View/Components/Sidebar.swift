//
//  Sidebar.swift
//  Mlem
//
//  Created by David Bureš on 08.05.2023.
//

import SwiftUI

struct CommunitySidebarView: View
{
    @State var account: SavedAccount
    @State var community: Community
    @Binding var isActive: Bool

    var body: some View
    {
        VStack(alignment: .leading, spacing: 0)
        {
            if community.details != nil
            {
                HStack(alignment: .center, spacing: 10) {
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(community.details!.numberOfSubscribers.formatted())
                        Text("subs")
                            .font(.caption)
                    }
                    .padding(.vertical, 5)
                    
                    Divider()
                    
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(community.details!.numberOfPosts.formatted())
                        Text("posts")
                            .font(.caption)
                    }
                    .padding(.vertical, 5)
                    
                    Divider()
                    
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(community.details!.numberOfUsersOnline.formatted())
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
                        if let communityDescription = community.description
                        {
                            MarkdownView(text: communityDescription)
                        }
                        else
                        {
                            Text("Community has no description")
                                .foregroundColor(.secondary)
                        }
                    }

                    NavigationLink
                    {
                        List
                        {
                            ForEach(community.details!.moderators)
                            { moderator in
                                UserProfileLink(account: account, user: moderator)
                            }
                        }
                        .navigationTitle("Moderators")
                        .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Text("Moderators")
                    }
                }
            }
            else
            {
                ProgressView
                {
                    Text("Loading details…")
                }
            }
        }
        .navigationTitle("Sidebar")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear
        {
            isActive = false
        }
    }
}
