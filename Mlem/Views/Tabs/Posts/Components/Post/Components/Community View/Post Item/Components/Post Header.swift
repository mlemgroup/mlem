//
//  Post Header.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-11.
//

import Foundation
import SwiftUI

struct PostHeader: View {
    // passed in
    var post: Post
    var account: SavedAccount
    
    // constants
    let communityIconSize: CGFloat = 30
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                // community avatar and name
                NavigationLink(destination: CommunityView(account: account, community: post.community, feedType: .all)) {
                    if let communityAvatarLink = post.community.icon {
                        AvatarView(avatarLink: communityAvatarLink, overridenSize: communityIconSize)
                    }
                    else {
                        Image("Default Community").frame(width: communityIconSize, height: communityIconSize)
                    }
                    Text(post.community.name)
                        .bold()
                }
                Text("by")
                // poster
                NavigationLink(destination: UserView(userID: post.author.id, account: account)) {
                    Text(post.author.name)
                        .italic()
                        .if(post.author.admin) { viewProxy in
                            viewProxy
                                .foregroundColor(.red)
                        }
                        .if(post.author.bot) { viewProxy in
                            viewProxy
                                .foregroundColor(.indigo)
                        }
                        .if(post.author.name == "lFenix") { viewProxy in
                            viewProxy
                                .foregroundColor(.yellow)
                        }
                }
            }
                
            Spacer()
            
            // ellipsis menu TODO: implement
            Image(systemName: "ellipsis")
                .foregroundColor(.secondary)
        }
        .foregroundColor(.secondary)
    }
}
