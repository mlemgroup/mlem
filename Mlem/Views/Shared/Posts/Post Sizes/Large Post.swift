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
    @ViewBuilder
    private var postBodyBackground: some View {
        switch layoutMode {
        case .minimize:
            Color.secondarySystemBackground
        default:
            Color.clear
        }
    }
    private var postBodyInsets: EdgeInsets {
        switch layoutMode {
        case .minimize:
            return .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        default:
            return .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        }
    }
    
    private func postBodyText(_ bodyText: String, layoutMode: LayoutMode) -> String {
        switch layoutMode {
        case .maximize:
            return bodyText
        case .preferredSize:
            return bodyText
                .components(separatedBy: .newlines)
                .joined(separator: " ")
        case .minimize:
            let lines = bodyText.components(separatedBy: .newlines)
            let endIndex = lines.index(lines.startIndex, offsetBy: 2, limitedBy: lines.endIndex) ?? lines.endIndex
            let sublines = lines[0..<endIndex].joined(separator: " ")
            return sublines
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
                if layoutMode != .minimize {
                    CachedImage(url: url,
                                maxHeight: maxHeight,
                                dismissCallback: markPostAsRead)
                    .frame(maxWidth: .infinity, maxHeight: maxHeight, alignment: .top)
                    .applyNsfwOverlay(postView.post.nsfw || postView.community.nsfw)
                    .cornerRadius(AppConstants.largeItemCornerRadius)
                    .clipped()
                }
                postBodyView
            }
        case .link:
            VStack(spacing: AppConstants.postAndCommentSpacing) {
                if layoutMode != .minimize {
                    WebsiteIconComplex(post: postView.post, onTapActions: markPostAsRead)
                }
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
                text: postBodyText(bodyText, layoutMode: layoutMode),
                isNsfw: postView.post.nsfw,
                replaceImagesWithEmoji: isExpanded ? false : true,
                isDeemphasized: isExpanded ? false : true
            )
            .id(postView.id)
            .font(.subheadline)
            .lineLimit(lineLimit)
            .padding(postBodyInsets)
            .background(postBodyBackground)
            .cornerRadius(8)
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
