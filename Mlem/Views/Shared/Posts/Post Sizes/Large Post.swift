//
//  Large Post Preview.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import Dependencies
import Foundation
import SwiftUI

struct LargePost: View {
    enum LayoutMode {
        case minimize, preferredSize, maximize
        
        func getMaxHeight(_ limitHeight: Bool = false) -> CGFloat {
            switch self {
            case .maximize:
                return .infinity
            case .preferredSize:
                return limitHeight ? AppConstants.maxFeedPostHeight : AppConstants.maxFeedPostHeightExpanded
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
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("limitImageHeightInFeed") var limitImageHeightInFeed: Bool = true
    @AppStorage("easyTapLinkDisplayMode") var easyTapLinkDisplayMode: EasyTapLinkDisplayMode = .contextual

    let post: any Post2Providing
    
    @Binding var layoutMode: LayoutMode
    private var isExpanded: Bool {
        layoutMode == .maximize
    }
    
    // computed
    var titleColor: Color { !isExpanded && post.isRead ? .secondary : .primary }
    
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
            let sublines = lines[0 ..< endIndex].joined(separator: " ")
            return sublines
        }
    }
    
    // initializer--used so we can set showNsfwFilterToggle to false when expanded or true when not
    init(
        post: any Post2Providing,
        layoutMode: Binding<LayoutMode>
    ) {
        self.post = post
        self._layoutMode = layoutMode
    }

    @State private var scaleX: CGFloat = 1
    @State private var scaleY: CGFloat = 1
        
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            postHeaderView
                .padding(postHeaderInsets)
                .background(postHeaderBackground)
                .cornerRadius(layoutMode == .minimize ? 8 : 0)
            if layoutMode != .minimize {
                postContentView
            }
        }
    }

    // MARK: - Subviews
    
    @ViewBuilder
    private var minimizedIcon: some View {
        Image(systemName: Icons.postSizeSetting)
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
                        removal: .push(from: .top)
                    ))
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
            if post.pinnedInstance {
                StickiedTag(tagType: .local)
            } else if post.pinnedCommunity {
                StickiedTag(tagType: .community)
            }
            
            Text("\(post.title)\(post.deleted ? " (Deleted)" : "")")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .italic(post.deleted)
                .foregroundColor(titleColor)
            
            Spacer()
            if post.nsfw {
                NSFWTag(compact: false)
            }
        }
        .scaleEffect(x: scaleX, y: scaleY)
        .onChange(of: layoutMode) {
            withAnimation(.easeOut(duration: 0.25)) {
                if layoutMode == .minimize {
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
        switch post.postType {
        case let .image(url):
            let limitHeight = limitImageHeightInFeed && !isExpanded
            VStack(spacing: AppConstants.postAndCommentSpacing) {
                if layoutMode != .minimize {
                    CachedImage(
                        url: url,
                        hasContextMenu: true,
                        maxHeight: layoutMode.getMaxHeight(limitHeight),
                        onTapCallback: markPostAsRead,
                        cornerRadius: AppConstants.largeItemCornerRadius
                    )
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: layoutMode.getMaxHeight(limitHeight),
                        alignment: .top
                    )
                    .applyNsfwOverlay(post.nsfw || post.community.nsfw, canTapFullImage: isExpanded)
                    .clipped()
                }
                postBodyView
            }
        case .link:
            VStack(spacing: AppConstants.postAndCommentSpacing) {
                if layoutMode != .minimize {
                    WebsiteIconComplex(post: post, onTapActions: markPostAsRead)
                }
                postBodyView
            }
        case let .text(postBody):
            // text posts need a little less space between title and body to look right, go figure
            postBodyView
                .padding(.top, postBody.isEmpty ? nil : -2)
        case .titleOnly:
            EmptyView()
        }
    }
    
    @ViewBuilder
    var postBodyView: some View {
        if let bodyText = post.content, !bodyText.isEmpty {
            VStack {
                MarkdownView(
                    text: postBodyText(bodyText, layoutMode: layoutMode),
                    isNsfw: post.nsfw,
                    replaceImagesWithEmoji: isExpanded ? false : true,
                    isInline: isExpanded ? false : true
                )
                .id(post.id)
                .font(.subheadline)
                .lineLimit(layoutMode.lineLimit)
                
                if layoutMode == .maximize, easyTapLinkDisplayMode != .disabled {
                    ForEach(post.links) { link in
                        EasyTapLinkView(linkType: link, showCaption: easyTapLinkDisplayMode != .compact)
                    }
                }
            }
        }
    }
    
    /// Synchronous void wrapper for apiClient.markPostAsRead to pass into CachedImage as dismiss callback
    func markPostAsRead() {
//        Task(priority: .userInitiated) {
//            await post.markRead(true)
//        }
    }
}
