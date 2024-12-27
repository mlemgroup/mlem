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
    @Environment(NavigationLayer.self) private var navigation
    @Environment(Palette.self) private var palette
    @Environment(FiltersTracker.self) var filtersTracker
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    
    @State var obscured: Bool
    
    @Setting(\.postSize) private var settingsPostSize
    @Setting(\.readPostIndicator) var readPostIndicator
    @Setting(\.readOutlineThickness) var readOutlineThickness
    
    let post: any Post1Providing
    let favoredLink: PostViewNavigationLink?
    let overridePostSize: PostSize?
    
    var postSize: PostSize {
        overridePostSize ?? settingsPostSize
    }
    
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
        self._obscured = .init(wrappedValue: FiltersTracker.main.postWouldBeFiltered(post))
    }
    
    var body: some View {
        Group {
            if obscured {
                obscuredContent
                    .onTapGesture {
                        withAnimation {
                            obscured = false
                        }
                    }
            } else {
                content
                    .overlay(alignment: .topLeading) {
                        if differentiateWithoutColor, !(post.read_ ?? false), readPostIndicator == .outline {
                            RoundedRectangle(cornerRadius: postSize.swipeBehavior.cornerRadius)
                                .stroke(lineWidth: .init(readOutlineThickness))
                                .foregroundStyle(palette.secondary)
                        }
                    }
                    .contentShape(.contextMenuPreview, .rect(cornerRadius: postSize.swipeBehavior.cornerRadius))
                    .quickSwipes(post.swipeActions(behavior: postSize.swipeBehavior))
                    .contextMenu { post.allMenuActions(
                        showAllActions: false,
                        navigation: navigation,
                        commentTreeTracker: commentTreeTracker
                    ) }
            }
        }
        .contentShape(.interaction, .rect)
        .paletteBorder(cornerRadius: postSize.swipeBehavior.cornerRadius)
        .onChange(of: filtersTracker.changeHash) {
            obscured = filtersTracker.postWouldBeFiltered(post)
        }
    }
    
    @ViewBuilder
    var obscuredContent: some View {
        Text("Hidden by keyword filters")
            .italic()
            .foregroundStyle(palette.secondary)
            .padding(Constants.main.standardSpacing)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(palette.secondaryGroupedBackground)
            .clipShape(.rect(cornerRadius: postSize.swipeBehavior.cornerRadius))
    }
    
    @ViewBuilder
    var content: some View {
        switch postSize {
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
