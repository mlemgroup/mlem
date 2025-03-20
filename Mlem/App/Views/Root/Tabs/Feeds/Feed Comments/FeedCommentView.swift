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
    
    var body: some View {
        VStack(spacing: Constants.main.standardSpacing) {
            if !postSize.tiled, let post = comment.post_ {
                headerView(post: post)
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
                .padding(.bottom, 5)
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
    func headerView(post: any Post) -> some View {
        HStack {
            MediaView(
                url: headerUrl(post: post),
                size: .init(width: 40, height: 40),
                controlState: .constant(.init(
                    blurred: post.nsfw && blurNsfw != .never,
                    animating: false,
                    overlays: []
                )),
                aspectRatioBounds: .absoluteSquare,
                contentMode: .fill,
                cornerRadius: 10,
                fallback: post.imageFallback
            )
            .frame(width: 40, height: 40)
            VStack(alignment: .leading) {
                Text(post.title)
                    .bold()
                Text(comment.community_?.fullName ?? "")
            }
            .lineLimit(1)
            .font(.footnote)
            .foregroundStyle(.themedSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 5)
        .onTapGesture {
            navigation.push(.post(post))
        }
    }
}
