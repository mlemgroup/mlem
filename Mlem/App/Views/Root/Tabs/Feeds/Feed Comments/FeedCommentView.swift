//
//  FeedCommentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-07-21.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct FeedCommentView<EmbeddedContent: View>: View {
    @Environment(AppState.self) private var appState
    @Environment(CommentTreeTracker.self) private var commentTreeTracker: CommentTreeTracker?
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.reportContext) var reportContext: Report?
    
    @Setting(\.postSize) var settingsPostSize
    @Setting(\.compactComments) var compactComments

    let comment: any Comment
    var overriddenSize: PostSize?
    @ViewBuilder var embeddedContent: () -> EmbeddedContent
    
    init(
        comment: any Comment,
        overriddenSize: PostSize? = nil,
        @ViewBuilder embeddedContent: @escaping () -> EmbeddedContent = { EmptyView() }
    ) {
        self.comment = comment
        self.overriddenSize = overriddenSize
        self.embeddedContent = embeddedContent
    }
    
    var postSize: PostSize { overriddenSize ?? settingsPostSize }
    
    var showCompactPostContext: Bool {
        postSize == .compact || compactComments
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if !postSize.tiled, let post = comment.post_ {
                if showCompactPostContext {
                    compactHeaderView(post: post)
                } else {
                    CommentContextHeaderView(post: post, community: comment.community_)
                        .padding(.top, Constants.main.halfSpacing)
                        .padding(.bottom, Constants.main.standardSpacing)
                }
            }
            content
                .contentShape(.interaction, .rect)
                .quickSwipes(
                    comment.swipeActions(appState: appState, behavior: postSize.swipeBehavior, commentTreeTracker: commentTreeTracker)
                )
                .contextMenu { comment.allMenuActions(
                    appState: appState,
                    showAllActions: false,
                    navigation: navigation,
                    commentTreeTracker: commentTreeTracker,
                    report: reportContext
                ) }
                .paletteBorder(cornerRadius: postSize.swipeBehavior.cornerRadius)
        }
    }
    
    @ViewBuilder
    var content: some View {
        if postSize.tiled {
            TileCommentView(comment: comment)
        } else {
            CommentView(comment: comment, inFeed: true, embeddedContent: embeddedContent)
        }
    }
    
    func headerUrl(post: any Post) -> URL? {
        switch post.type {
        case let .media(url), let .embedded(url, _): url
        case let .link(link): link.thumbnail
        default: nil
        }
    }
    
    @ViewBuilder
    func compactHeaderView(post: any Post) -> some View {
        Label(post.title, systemImage: Icons.posts)
            .font(.footnote)
            .foregroundStyle(.themedSecondary)
            .lineLimit(1)
            .padding(.leading, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, postSize == .compact ? 3 : 5)
    }
}
