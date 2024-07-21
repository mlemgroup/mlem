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
    @AppStorage("beta.tilePosts") var tilePosts: Bool = false
    
    @Environment(Palette.self) var palette
    
    let comment: Comment2
    
    var body: some View {
        content
            .contentShape(.interaction, .rect)
            .quickSwipes(comment.swipeActions(behavior: tilePosts ? .tile : .standard))
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
