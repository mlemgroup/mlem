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
    @Environment(CommentTreeTracker.self) private var commentTreeTracker: CommentTreeTracker?
    @Environment(Palette.self) var palette
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
        content
            .contentShape(.interaction, .rect)
            .quickSwipes(comment.swipeActions(behavior: postSize.swipeBehavior, commentTreeTracker: commentTreeTracker))
            .contextMenu { comment.allMenuActions(report: reportContext) }
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
}
