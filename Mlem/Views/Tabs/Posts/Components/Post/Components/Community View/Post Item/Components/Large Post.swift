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
    @EnvironmentObject var postTracker: PostTracker
    @EnvironmentObject var appState: AppState
    
    // parameters
    let post: APIPostView
    let account: SavedAccount
    let isExpanded: Bool
    let voteOnPost: (ScoringOperation) async -> Bool
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
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
                                .scaledToFill()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(.secondary, lineWidth: 1))
                                .padding(.horizontal)
                            
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    
                    // web post: display link
                    else {
                        WebsiteIconComplex(post: post.post)
                            .padding(.horizontal)
                    }
                }
                else if let postBody = post.post.body {
                    if !postBody.isEmpty {
                        if isExpanded {
                            MarkdownView(text: postBody)
                                .font(.subheadline)
                                .padding(.horizontal)
                        } else {
                            MarkdownView(text: postBody.components(separatedBy: .newlines).joined())
                                .lineLimit(8)
                                .font(.subheadline)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            
            PostInteractionBar(post: post, account: account, compact: false, voteOnPost: voteOnPost)
        }
    }
}
