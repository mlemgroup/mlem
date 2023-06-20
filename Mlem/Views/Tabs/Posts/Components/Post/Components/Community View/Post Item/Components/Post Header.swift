//
//  Post Header.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-11.
//

import Foundation
import SwiftUI
import CachedAsyncImage

struct PostHeader: View {
    // parameters
    var post: APIPostView
    var account: SavedAccount
    
    // constants
    private let communityIconSize: CGFloat = 32
    private let defaultCommunityIconSize: CGFloat = 24 // a little smaller so it looks nice
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                // community avatar and name
                NavigationLink(destination: CommunityView(account: account, community: post.community, feedType: .all)) {
                    communityAvatar
                        .frame(width: communityIconSize, height: communityIconSize)
                        .clipShape(Circle())
                        .overlay(Circle()
                            .stroke(.secondary, lineWidth: 1))
                    Text(post.community.name)
                        .bold()
                }
                Text("by")
                // poster
                NavigationLink(destination: UserView(userID: post.creator.id, account: account)) {
                    Text(post.creator.name)
                        .italic()
                        .if(post.creator.admin) { viewProxy in
                            viewProxy
                                .foregroundColor(.red)
                        }
                        .if(post.creator.botAccount) { viewProxy in
                            viewProxy
                                .foregroundColor(.indigo)
                        }
                        .if(post.creator.name == "lFenix") { viewProxy in
                            viewProxy
                                .foregroundColor(.yellow)
                        }
                }
            }
            
            Spacer()
            
            if (post.post.featuredLocal) {
                StickiedTag(compact: false)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityLabel("in \(post.community.name) by \(post.creator.name)")
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    private var communityAvatar: some View {
        Group {
            if let communityAvatarLink = post.community.icon {
                CachedAsyncImage(url: communityAvatarLink) { image in
                    if let avatar = image.image {
                        avatar
                            .resizable()
                            .scaledToFit()
                            .frame(width: communityIconSize, height: communityIconSize)
                    }
                    else {
                        Image("Default Community")
                            .resizable()
                            .scaledToFit()
                            .frame(width: defaultCommunityIconSize, height: defaultCommunityIconSize)
                    }
                }
            }
            else {
                Image("Default Community")
                    .resizable()
                    .scaledToFit()
                    .frame(width: defaultCommunityIconSize, height: defaultCommunityIconSize)
            }
        }
        .accessibilityHidden(true)
    }
}
