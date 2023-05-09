//
//  Sidebar.swift
//  Mlem
//
//  Created by David Bureš on 08.05.2023.
//

import SwiftUI

struct CommunitySidebarView: View
{
    @State var community: Community
    @Binding var isActive: Bool

    var body: some View
    {
        VStack(alignment: .leading, spacing: 0)
        {
            if community.details != nil
            {
                HStack(alignment: .center, spacing: 10) {
                    Text("\(community.details!.numberOfSubscribers.formatted(.number)) subs")
                    
                    
                    Text("\(community.details!.numberOfPosts.formatted(.number)) posts")
                }
                .frame(maxWidth: .infinity)
                .background(.thinMaterial)
                
                Divider()
                
                List
                {
                    Section("Description")
                    {
                        if let communityDescription = community.description
                        {
                            Text(.init(communityDescription))
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
                                UserProfileLink(user: moderator)
                            }
                        }
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
        .onDisappear
        {
            isActive = false
        }
    }
}
