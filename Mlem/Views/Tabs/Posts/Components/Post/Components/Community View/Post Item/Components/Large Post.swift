//
//  Large Post Preview.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import CachedAsyncImage
import SwiftUI

import Foundation

struct LargePost: View {
    let communityIconSize: CGFloat = 30
    
    // @EnvironmentObject var postTracker: PostTracker
    @State var postTracker: PostTracker
    let account: SavedAccount
    let post: APIPostView
    
    /**
     Whether the post is expanded or in feed
     */
    let isExpanded: Bool
    
    var body: some View {
        VStack() {
            // header--community/poster/ellipsis menu
            PostHeader(post: post, account: account)
                .padding(.horizontal)
            
            // post title
            Text(post.post.name)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                // no padding if text post with no body
                .if(post.post.url != nil || !(post.post.body?.isEmpty ?? true)) { viewProxy in
                    viewProxy.padding(.bottom)
                }
                .padding(.horizontal)
            
            // post body preview
            if let postURL = post.post.url {
                // image post: display image
                if postURL.pathExtension.contains(["jpg", "jpeg", "png"]) {
                    CachedAsyncImage(url: postURL) { image in
                        image
                            .resizable()
                            .frame(maxWidth: .infinity)
                            .scaledToFit()
                            .padding(.horizontal)
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                // web post: display link
                else {
                    WebsiteIconComplex(post: post.post)
                }
            }
            else if let postBody = post.post.body {
                if !postBody.isEmpty {
                    // TODO: visual indicator of truncation. This is way harder than it seems :(
                    MarkdownView(text: postBody)
                        .padding(.horizontal)
                        .if(!isExpanded) { viewProxy in
                            viewProxy
                                .frame(maxHeight: 200, alignment: .topLeading)
                                .clipShape(Rectangle())
                                
                        }
                }
            }
            
            PostInteractionBar(postTracker: postTracker, post: post, account: account, compact: false)
        }
    }
}
