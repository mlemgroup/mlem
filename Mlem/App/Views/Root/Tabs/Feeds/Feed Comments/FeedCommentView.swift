//
//  FeedCommentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-07-21.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct FeedCommentView: View {
    @Config(\.postSize) var postSize
    @Environment(Palette.self) var palette
    
    let comment: Comment2
    
    var body: some View {
        content
            .contentShape(.interaction, .rect)
            .quickSwipes(comment.swipeActions(behavior: postSize.swipeBehavior))
            .contextMenu(actions: comment.menuActions())
            .shadow(color: postSize.tiled ? palette.primary.opacity(0.1) : .clear, radius: 3) // after quickSwipes to prevent clipping
    }
    
    @ViewBuilder
    var content: some View {
        if postSize.tiled {
            TileCommentView(comment: comment)
        } else {
            CommentView(comment: comment, inFeed: true)
        }
    }
}
