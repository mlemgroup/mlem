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
    @AppStorage("post.size") var postSize: PostSize = .large
    @Environment(Palette.self) var palette
    
    let comment: Comment2
    
    var tilePosts: Bool { postSize == .tile }
    
    var body: some View {
        content
            .contentShape(.interaction, .rect)
            .quickSwipes(comment.swipeActions(behavior: postSize.swipeBehavior))
            .contextMenu(actions: comment.menuActions())
            .shadow(color: tilePosts ? palette.primary.opacity(0.1) : .clear, radius: 3) // after quickSwipes to prevent getting clipped
    }
    
    @ViewBuilder
    var content: some View {
        if tilePosts {
            TileCommentView(comment: comment)
        } else {
            CommentView(comment: comment, inFeed: true)
        }
    }
}
