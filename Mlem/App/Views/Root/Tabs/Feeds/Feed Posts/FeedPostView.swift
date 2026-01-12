//
//  FeedPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-05.
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
    
    let post: Post
    let favoredLink: PostViewNavigationLink?
    let requireConsistentHeight: Bool
    @State var overridePostSize: PostSize?
    
    var postSize: PostSize { overridePostSize ?? settingsPostSize }
    
    @ViewBuilder let embeddedContent: () -> EmbeddedContent
    
    init(
        post: Post,
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
                        if differentiateWithoutColor, !(post.read.value ?? false), readPostIndicator == .outline {
                            RoundedRectangle(cornerRadius: postSize.cornerRadius)
                                .stroke(lineWidth: .init(readOutlineThickness))
                                .foregroundStyle(.themedSecondary)
                        }
                    }
                    .contentShape(.contextMenuPreview, .rect(cornerRadius: postSize.cornerRadius))
                    .quickSwipes(post: post, configuration: interactionBarConfiguration)
                    .contextMenu { post.allMenuActions(
                        appState: appState,
                        showAllActions: false,
                        navigation: navigation,
                        report: reportContext,
                        commentTreeTracker: commentTreeTracker
                    ) }
            }
        }
        .contentShape(.interaction, .rect)
        .paletteBorder(cornerRadius: postSize.cornerRadius)
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
        .onChange(of: post.read.value) {
            if shouldRenderCompact() {
                withAnimation {
                    overridePostSize = .compact
                }
            }
        }
    }
    
    @ViewBuilder
    var obscuredContent: some View {
        Text("Hidden by filters")
            .italic()
            .foregroundStyle(.themedSecondary)
            .padding(Constants.main.standardSpacing)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(.themedSecondaryGroupedBackground)
            .clipShape(.rect(cornerRadius: postSize.cornerRadius))
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
        return post.read.value ?? false &&
            ((communityContext == nil && post.pinnedInstance) || (communityContext != nil && post.pinnedCommunity))
    }
}
