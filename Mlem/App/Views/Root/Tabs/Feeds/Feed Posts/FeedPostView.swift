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
    @Environment(AppState.self) private var appState: AppState
    @Environment(CommentTreeTracker.self) private var commentTreeTracker: CommentTreeTracker?
    @Environment(NavigationLayer.self) private var navigation
    @Environment(FiltersTracker.self) var filtersTracker
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.communityContext) var communityContext
    @Environment(\.reportContext) var reportContext
    
    @State var obscured: Bool
    
    @Setting(\.post_size) private var settingsPostSize
    @Setting(\.a11y_readPostIndicator) var readPostIndicator
    @Setting(\.a11y_readOutlineThickness) var readOutlineThickness
    @Setting(\.interactionBar_post) var postInteractionBar
    @Setting(\.interactionBar_postReport) var postReportInteractionBar
    @Setting(\.interactionBar_alternateReportLayout) var alternateInteractionBarLayoutForReports
    
    let post: any Post1Providing
    let favoredLink: PostViewNavigationLink?
    let requireConsistentHeight: Bool
    @State var overridePostSize: PostSize?
    
    var postSize: PostSize { overridePostSize ?? settingsPostSize }
    
    @ViewBuilder let embeddedContent: () -> EmbeddedContent
    
    init(
        post: any Post1Providing,
        overridePostSize: PostSize? = nil,
        favoredLink: PostViewNavigationLink? = nil,
        requireConsistentHeight: Bool = false,
        @ViewBuilder embeddedContent: @escaping () -> EmbeddedContent = { EmptyView() }
    ) {
        self.post = post
        self.favoredLink = favoredLink
        self.requireConsistentHeight = requireConsistentHeight
        self.embeddedContent = embeddedContent
        self._obscured = .init(wrappedValue: FiltersTracker.main.postWouldBeFiltered(post))
        self._overridePostSize = .init(wrappedValue: overridePostSize)
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
                                .foregroundStyle(.themedSecondary)
                        }
                    }
                    .contentShape(.contextMenuPreview, .rect(cornerRadius: postSize.swipeBehavior.cornerRadius))
                    .quickSwipes(
                        post: post,
                        configuration: interactionBarConfiguration,
                        behavior: .standard
                    )
                    .contextMenu { post.allMenuActions(
                        appState: appState,
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
        .onAppear {
            if shouldRenderCompact() {
                overridePostSize = .compact
            }
        }
        .onChange(of: settingsPostSize) {
            if settingsPostSize == .tile {
                overridePostSize = nil
            } else if shouldRenderCompact() {
                overridePostSize = .compact
            }
        }
        .onChange(of: post.read_) {
            if shouldRenderCompact() {
                withAnimation {
                    overridePostSize = .compact
                }
            }
        }
    }
    
    @ViewBuilder
    var obscuredContent: some View {
        Text("Hidden by keyword filters")
            .italic()
            .foregroundStyle(.themedSecondary)
            .padding(Constants.main.standardSpacing)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(.themedSecondaryGroupedBackground)
            .clipShape(.rect(cornerRadius: postSize.swipeBehavior.cornerRadius))
    }
    
    @ViewBuilder
    var content: some View {
        switch postSize {
        case .compact:
            CompactPostView(post: post, requireConsistentHeight: requireConsistentHeight)
        case .tile:
            TilePostView(post: post)
        case .headline:
            HeadlinePostView(
                post: post,
                favoredLink: favoredLink,
                requireConsistentHeight: requireConsistentHeight,
                embeddedContent: embeddedContent
            )
        case .large:
            LargePostView(post: post, favoredLink: favoredLink)
        }
    }
    
    var interactionBarConfiguration: PostBarConfiguration {
        if reportContext != nil, alternateInteractionBarLayoutForReports {
            return postReportInteractionBar
        }
        return postInteractionBar
    }
    
    func shouldRenderCompact() -> Bool {
        guard settingsPostSize != .tile, settingsPostSize != .compact else { return false }
        return post.read_ ?? false &&
            ((communityContext == nil && post.pinnedInstance) || (communityContext != nil && post.pinnedCommunity))
    }
}
