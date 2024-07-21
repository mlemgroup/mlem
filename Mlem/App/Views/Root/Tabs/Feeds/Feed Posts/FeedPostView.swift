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
    @AppStorage("post.size") var size: PostSize = .large
    @AppStorage("beta.tilePosts") var tilePosts: Bool = false
    
    @Environment(Palette.self) var palette
    
    let post: any Post1Providing
    
    var body: some View {
        content
            .contentShape(.interaction, .rect)
            .quickSwipes(post.swipeActions(behavior: tilePosts ? .tile : .standard))
            .contextMenu(actions: post.menuActions())
            .shadow(color: tilePosts ? palette.primary.opacity(0.1) : .clear, radius: 3) // after quickSwipes to prevent getting clipped
    }
    
    @ViewBuilder
    var content: some View {
        if tilePosts {
            TilePostView(post: post)
        } else {
            switch size {
            case .compact:
                CompactPostView(post: post)
            case .headline:
                HeadlinePostView(post: post)
            case .large:
                LargePostView(post: post)
            }
        }
    }
}
