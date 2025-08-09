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
    
    @Setting(\.post_size) var settingsPostSize
    @Setting(\.comment_compact) var compactComments
    @Setting(\.interactionBar_comment) var commentInteractionBar
    @Setting(\.interactionBar_commentReport) var commentReportInteractionBar
    @Setting(\.interactionBar_alternateReportLayout) var alternateInteractionBarLayoutForReports: Bool

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
        content
            .contentShape(.interaction, .rect)
            .quickSwipes(
                comment: comment,
                configuration: interactionBarConfiguration,
                behavior: postSize.swipeBehavior
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
    
    var interactionBarConfiguration: CommentBarConfiguration {
        if reportContext != nil, alternateInteractionBarLayoutForReports {
            return commentReportInteractionBar
        }
        return commentInteractionBar
    }
}
