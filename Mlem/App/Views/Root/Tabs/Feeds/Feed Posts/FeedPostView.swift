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
struct FeedPostView: View {
    @Config(\.postSize) var postSize
    
    @Environment(Palette.self) var palette
    
    let post: any Post1Providing
    
    var body: some View {
        content
            .contentShape(.interaction, .rect)
            .quickSwipes(post.swipeActions(behavior: postSize.swipeBehavior))
            .contextMenu(actions: post.menuActions())
            .shadow(color: postSize.tiled ? palette.primary.opacity(0.1) : .clear, radius: 3) // after quickSwipes to prevent clipping
    }
    
    @ViewBuilder
    var content: some View {
        switch postSize {
        case .compact:
            CompactPostView(post: post)
        case .tile:
            TilePostView(post: post)
        case .headline:
            HeadlinePostView(post: post)
        case .large:
            LargePostView(post: post)
        }
    }
}
