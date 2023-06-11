//
//  Large Post Preview.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import CachedAsyncImage
import SwiftUI

import Foundation

struct LargePostPreview: View {
    let communityIconSize: CGFloat = 30
    
    let post: Post
    
    var account: SavedAccount
    
    var body: some View {
        VStack {
            // header--community/poster/ellipsis menu
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
            
            // post title
            Text(post.name)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                // no padding if text post with no body
                .if(post.url != nil || !(post.body?.isEmpty ?? true)) { viewProxy in
                    viewProxy.padding(.bottom)
                }
            
            // post body preview
            if let postURL = post.url {
                // image post: display image
                if postURL.pathExtension.contains(["jpg", "jpeg", "png"]) {
                    CachedAsyncImage(url: postURL) { image in
                        image
                            .resizable()
                            .frame(maxWidth: .infinity)
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                // web post: display link
                else {
                    WebsiteIconComplex(post: post)
                }
            }
            
            // text post: display first 10 lines of text
            // TODO: wrap this in a card that fades bottom
            else if let postBody = post.body {
                if !postBody.isEmpty {
                    MarkdownView(text: postBody)
                        .frame(maxHeight: 200)
//                    let markdownText = LocalizedStringKey(postBody)
//                    Text(markdownText)
//                        .lineLimit(40)
//                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.horizontal)
    }
}
