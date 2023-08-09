//
//  Large Post Preview.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import Foundation
import SwiftUI
import Dependencies

struct LargePost: View {
    
    enum LayoutMode {
        case minimize, preferredSize, maximize
    }
    
    // constants
    private let spacing: CGFloat = 10 // constant for readability, ease of modification

    @Dependency(\.postRepository) var postRepository
    @Dependency(\.errorHandler) var errorHandler
    
    // global state
    @EnvironmentObject var postTracker: PostTracker
    @EnvironmentObject var appState: AppState
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true

    // parameters
    let postView: APIPostView
    
    @Binding var layoutMode: LayoutMode
    private var isExpanded: Bool {
        layoutMode == .maximize
    }
    
    // computed
    private var maxHeight: CGFloat {
        switch layoutMode {
        case .maximize:
            return .infinity
        case .preferredSize:
            return AppConstants.maxFeedPostHeight
        case .minimize:
            return 44
        }
    }
    var titleColor: Color { !isExpanded && postView.read ? .secondary : .primary }
    private var lineLimit: Int? {
        switch layoutMode {
        case .maximize:
            return nil
        case .preferredSize:
            return 8
        case .minimize:
            return 2
        }
    }
    
    // initializer--used so we can set showNsfwFilterToggle to false when expanded or true when not
    init(
        postView: APIPostView,
        layoutMode: Binding<LayoutMode>) {
        self.postView = postView
        self._layoutMode = layoutMode
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
                    .foregroundColor(titleColor)
                
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
                CachedImage(url: url,
                            maxHeight: maxHeight,
                            dismissCallback: markPostAsRead)
                    .frame(maxWidth: .infinity, maxHeight: maxHeight, alignment: .top)
                    .applyNsfwOverlay(postView.post.nsfw || postView.community.nsfw)
                    .cornerRadius(AppConstants.largeItemCornerRadius)
                    .clipped()
                postBodyView
            }
        case .link:
            VStack(spacing: AppConstants.postAndCommentSpacing) {
                WebsiteIconComplex(post: postView.post, onTapActions: markPostAsRead)
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
            MarkdownView(
                text: isExpanded ? bodyText : bodyText.components(separatedBy: .newlines).joined(separator: " "),
                isNsfw: postView.post.nsfw,
                replaceImagesWithEmoji: isExpanded ? false : true,
                isDeemphasized: isExpanded ? false : true
            )
            .lineLimit(lineLimit)
            .font(.subheadline)
        }
    }
    
    /**
     Synchronous void wrapper for apiClient.markPostAsRead to pass into CachedImage as dismiss callback
     */
    func markPostAsRead() {
        Task(priority: .userInitiated) {
            do {
                let readPost = try await postRepository.markRead(for: postView.post.id, read: true)
                postTracker.update(with: readPost)
            } catch {
                errorHandler.handle(.init(underlyingError: error))
            }
        }
    }
}
