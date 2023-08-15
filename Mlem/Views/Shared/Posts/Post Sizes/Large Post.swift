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
        
        var maxHeight: CGFloat {
            switch self {
            case .maximize:
                return .infinity
            case .preferredSize:
                return AppConstants.maxFeedPostHeight
            case .minimize:
                return 44
            }
        }
        
        var lineLimit: Int? {
            switch self {
            case .maximize:
                return nil
            case .preferredSize:
                return 8
            case .minimize:
                return 2
            }
        }
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
    var titleColor: Color { !isExpanded && postView.read ? .secondary : .primary }
    
    @ViewBuilder
    private var postBodyBackground: some View {
        if layoutMode == .minimize {
            Color.secondarySystemBackground
        } else {
            Color.clear
        }
    }
    
    private var postBodyInsets: EdgeInsets {
        if layoutMode == .minimize {
            return .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        } else {
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

    @State private var scaleX: CGFloat = 1
    @State private var scaleY: CGFloat = 1
        
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            postHeaderView
                .padding(postHeaderInsets)
                .background(postHeaderBackground)
                .cornerRadius(8)
            if layoutMode != .minimize {
                postContentView
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if layoutMode == .minimize {
                minimizedIcon
            }
        }
    }

    // MARK: - Subviews
    
    @ViewBuilder
    private var minimizedIcon: some View {
        Image(systemName: "rectangle.expand.vertical")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(6)
            .frame(width: 28, height: 28, alignment: .center)
            .background(.regularMaterial)
            .clipShape(Circle())
            .offset(.init(width: -8, height: -8))
            .shadow(radius: 4)
            .transition(
                .scale(scale: 1.5, anchor: .leading)
                .combined(with: .asymmetric(
                    insertion: .push(from: .bottom),
                    removal: .push(from: .top)))
                .combined(with: .opacity)
            )
            .accessibilityLabel("Post content is minimized.")
            .accessibilityHint("Expands post content.")
    }
    
    private var postHeaderInsets: EdgeInsets {
        if layoutMode == .minimize {
            /// - Warning: Keep leading/trailing = 0, otherwise you'll trigger system animations for Text, which moves whole words around...unless that's what you want =) [2023.08]
            return .init(top: 12, leading: 0, bottom: 12, trailing: 0)
        } else {
            return .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        }
    }
    
    @ViewBuilder
    private var postHeaderBackground: some View {
        if layoutMode == .minimize {
            Color.secondarySystemBackground
        } else {
            Color.clear
        }
    }
    
    @ViewBuilder
    private var postHeaderView: some View {
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
        .scaleEffect(x: scaleX, y: scaleY)
        .onChange(of: layoutMode) { newValue in
            withAnimation(.easeOut(duration: 0.25)) {
                if newValue == .minimize {
                    scaleX = 0.95
                    scaleY = 0.95
                } else {
                    scaleX = 1
                    scaleY = 1
                }
            }
        }
    }
    
    @ViewBuilder
    var postContentView: some View {
        switch postView.postType {
        case .image(let url):
            VStack(spacing: AppConstants.postAndCommentSpacing) {
                if layoutMode != .minimize {
                    CachedImage(url: url,
                                maxHeight: .infinity,
                                dismissCallback: markPostAsRead,
                                padding: AppConstants.compactSpacing)
                    .cornerRadius(AppConstants.largeItemCornerRadius)
                    .padding(.horizontal, -AppConstants.compactSpacing)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .applyNsfwOverlay(postView.post.nsfw || postView.community.nsfw)
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
                text: bodyText,
                isNsfw: postView.post.nsfw,
                replaceImagesWithEmoji: isExpanded ? false : true,
                isDeemphasized: isExpanded ? false : true
            )
            .id(postView.id)
            .font(.subheadline)
            .lineLimit(layoutMode.lineLimit)
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
