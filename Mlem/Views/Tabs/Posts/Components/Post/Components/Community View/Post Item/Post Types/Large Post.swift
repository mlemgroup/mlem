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
    // constants
    private let spacing: CGFloat = 10 // constant for readability, ease of modification

    // global state
    @EnvironmentObject var postTracker: PostTracker
    @EnvironmentObject var appState: AppState
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true

    // parameters
    let postView: APIPostView
    let isExpanded: Bool

    // initializer--used so we can set showNsfwFilterToggle to false when expanded or true when not
    init(
        postView: APIPostView,
        isExpanded: Bool
    ) {
        self.postView = postView
        self.isExpanded = isExpanded
    }

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            // post title
            HStack {
                if postView.post.featuredLocal {
                    StickiedTag(tagType: .local)
                } else if postView.post.featuredCommunity {
                    StickiedTag(tagType: .community)
                }
                
                Text("\(postView.post.name)\(postView.post.deleted ? " (Deleted)" : "")")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .italic(postView.post.deleted)
                
                Spacer()
                if postView.post.nsfw {
                    NSFWTag(compact: false)
                }
            }
            
            postContentView
        }
    }

    // MARK: - Subviews
    
    @ViewBuilder
    var postContentView: some View {
        switch postView.postType {
        case .image(let url):
            VStack(spacing: AppConstants.postAndCommentSpacing) {
                CachedImageWithNsfwFilter(isNsfw: postView.post.nsfw, url: url)
                    .frame(maxWidth: .infinity, maxHeight: isExpanded ? .infinity : AppConstants.maxFeedPostHeight, alignment: .center)
                    .cornerRadius(AppConstants.largeItemCornerRadius)
                    .clipped()
                postBodyView
            }
        case .link:
            VStack(spacing: AppConstants.postAndCommentSpacing) {
                WebsiteIconComplex(post: postView.post)
                postBodyView
            }
        case .text(let postBody):
            // text posts need a little less space between title and body to look right, go figure
            postBodyView
                .padding(.top, postBody.isEmpty ? nil : -2)
        case .titleOnly:
            EmptyView()
        }
    }
    
    @ViewBuilder
    var postBodyView: some View {
        if let bodyText = postView.post.body, !bodyText.isEmpty {
            if isExpanded {
                MarkdownView(text: bodyText, isNsfw: postView.post.nsfw)
                    .font(.subheadline)
            } else {
                MarkdownView(text: bodyText.components(separatedBy: .newlines).joined(separator: " "),
                             isNsfw: postView.post.nsfw,
                             replaceImagesWithEmoji: true)
                    .lineLimit(8)
                    .font(.subheadline)
            }
        }
    }
}
