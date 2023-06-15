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
    private let spacing: CGFloat = 10 // constant for readability, ease of modification
    
    @EnvironmentObject var postTracker: PostTracker
    @EnvironmentObject var appState: AppState
    
    // parameters
    let postView: APIPostView
    let account: SavedAccount
    let isExpanded: Bool
    let voteOnPost: (ScoringOperation) async -> Void
    
    var body: some View {
        VStack(spacing: spacing) {
            // header--community/poster/ellipsis menu
            PostHeader(postView: postView, account: account)
                .padding(.bottom, -2) // negative padding to crunch header and title together just a wee bit
            
            // post title
            Text(postView.post.name)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // post body
            switch postView.postType {
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
                    
                } placeholder: {
                    ProgressView()
                }
                postBodyView
            case .link:
                WebsiteIconComplex(post: postView.post)
            case .text(let postBody):
                // text posts need a little less space between title and body to look right, go figure
                postBodyView
                    .padding(.top, postBody.isEmpty ? nil : -2)
            case .titleOnly:
                EmptyView()
            }
            
            PostInteractionBar(post: postView, account: account, compact: false, voteOnPost: voteOnPost)
        }
        .padding(.vertical, spacing)
        .padding(.horizontal, spacing)
        .accessibilityElement(children: .combine)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    var postBodyView: some View {
        if let bodyText = post.post.body, !bodyText.isEmpty {
            if isExpanded {
                MarkdownView(text: bodyText)
                    .font(.subheadline)
            } else {
                MarkdownView(text: bodyText.components(separatedBy: .newlines).joined())
                    .lineLimit(8)
                    .font(.subheadline)
            }
        }
    }
}
