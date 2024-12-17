//
//  FeedPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

/// View for rendering posts in feed
struct FeedPostView<EmbeddedContent: View>: View {
    @Environment(CommentTreeTracker.self) private var commentTreeTracker: CommentTreeTracker?
    @Environment(Palette.self) private var palette
    
    @Setting(\.postSize) private var postSize
    
    let post: any Post1Providing
    let favoredLink: PostViewNavigationLink?
    let overridePostSize: PostSize?
    
    @ViewBuilder let embeddedContent: () -> EmbeddedContent
    
    init(
        post: any Post1Providing,
        overridePostSize: PostSize? = nil,
        favoredLink: PostViewNavigationLink? = nil,
        @ViewBuilder embeddedContent: @escaping () -> EmbeddedContent = { EmptyView() }
    ) {
        self.post = post
        self.overridePostSize = overridePostSize
        self.favoredLink = favoredLink
        self.embeddedContent = embeddedContent
    }
    
    var body: some View {
        content
            .contentShape(.interaction, .rect)
            .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
            .quickSwipes(post.swipeActions(behavior: postSize.swipeBehavior))
            .contextMenu { post.allMenuActions(showAllActions: false, commentTreeTracker: commentTreeTracker) }
            .paletteBorder(cornerRadius: postSize.swipeBehavior.cornerRadius)
    }
    
    @ViewBuilder
    var content: some View {
        switch overridePostSize ?? postSize {
        case .compact:
            CompactPostView(post: post)
        case .tile:
            TilePostView(post: post)
        case .headline:
            HeadlinePostView(post: post, favoredLink: favoredLink, embeddedContent: embeddedContent)
        case .large:
            LargePostView(post: post, favoredLink: favoredLink)
        }
    }
}
