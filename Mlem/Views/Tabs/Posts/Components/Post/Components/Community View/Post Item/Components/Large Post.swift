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
    let postView: APIPostView
    let account: SavedAccount
    let isExpanded: Bool
    let voteOnPost: (ScoringOperation) async -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            // VStack {
                // header--community/poster/ellipsis menu
                PostHeader(postView: postView, account: account)
                
                // post title
                Text(postView.post.name)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    // no padding iff text post with no body
                    .padding(.bottom, post.postType == .titleOnly ? 0 : nil)
                
                switch post.postType {
                case .image(let url):
                    CachedAsyncImage(url: url) { image in
                        image
                            .resizable()
                            .frame(maxWidth: .infinity)
                            .scaledToFill()
                            .blur(radius: postView.post.nsfw && !isExpanded ? 30 : 0)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(.secondary, lineWidth: 1))
                            .padding(.horizontal)
                        
                    } placeholder: {
                        ProgressView()
                    }
                    postBodyView
                case .link:
                    WebsiteIconComplex(post: postView.post)
                        .padding(.horizontal)
                    postBodyView
                case .text:
                    postBodyView
                case .titleOnly:
                    EmptyView()
                }
            }
            
            PostInteractionBar(post: postView, account: account, compact: false, voteOnPost: voteOnPost)
        }
        .accessibilityElement(children: .combine)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    var postBodyView: some View {
        if let bodyText = post.post.body, !bodyText.isEmpty {
            if isExpanded {
                MarkdownView(text: bodyText)
                    .font(.subheadline)
                    .padding(.horizontal)
            } else {
                MarkdownView(text: bodyText.components(separatedBy: .newlines).joined())
                    .lineLimit(8)
                    .font(.subheadline)
                    .padding(.horizontal)
            }
        }
    }
}
