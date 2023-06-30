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
    let account: SavedAccount
    let isExpanded: Bool

    // initializer--used so we can set showNsfwFilterToggle to false when expanded or true when not
    init(
        postView: APIPostView,
        account: SavedAccount,
        isExpanded: Bool
    ) {
        self.postView = postView
        self.account = account
        self.isExpanded = isExpanded
    }

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            // post title
            Text("\(postView.post.name)\(postView.post.deleted ? " (Deleted)" : "")")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .italic(postView.post.deleted)

            // post body
            switch postView.postType {
            case .image(let url):
                CachedImageWithNsfwFilter(isNsfw: postView.post.nsfw, url: url)
                postBodyView
            case .link:
                WebsiteIconComplex(post: postView.post)
                postBodyView
            case .text(let postBody):
                // text posts need a little less space between title and body to look right, go figure
                postBodyView
                    .padding(.top, postBody.isEmpty ? nil : -2)
            case .titleOnly:
                EmptyView()
            }
        }
    }

    // MARK: - Subviews
    
    @ViewBuilder
    var postBodyView: some View {
        if let bodyText = postView.post.body, !bodyText.isEmpty {
            if isExpanded {
                MarkdownView(text: bodyText, isNsfw: postView.post.nsfw)
                    .font(.subheadline)
            } else {
                MarkdownView(text: bodyText.components(separatedBy: .newlines).joined(separator: " "), isNsfw: postView.post.nsfw)
                    .lineLimit(8)
                    .font(.subheadline)
            }

        }
    }

}
