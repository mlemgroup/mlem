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
    
    @Setting(\.postSize) var postSize
    
    let comment: any Comment
    var overrideIsTiled: Bool?
    @ViewBuilder var embeddedContent: () -> EmbeddedContent
    
    init(
        comment: any Comment,
        overrideIsTiled: Bool? = nil,
        @ViewBuilder embeddedContent: @escaping () -> EmbeddedContent = { EmptyView() }
    ) {
        self.comment = comment
        self.overrideIsTiled = overrideIsTiled
        self.embeddedContent = embeddedContent
    }
    
    var overridenSize: PostSize {
        if let overrideIsTiled {
            return overrideIsTiled ? .tile : .large
        }
        return postSize
    }
    
    var body: some View {
        content
            .contentShape(.interaction, .rect)
            .quickSwipes(comment.swipeActions(behavior: overridenSize.swipeBehavior, commentTreeTracker: commentTreeTracker))
            .contextMenu { comment.allMenuActions(report: reportContext) }
            .paletteBorder(cornerRadius: postSize.swipeBehavior.cornerRadius)
    }
    
    @ViewBuilder
    var content: some View {
        if overridenSize.tiled {
            TileCommentView(comment: comment)
        } else {
            CommentView(comment: comment, inFeed: true, embeddedContent: embeddedContent)
        }
    }
}
