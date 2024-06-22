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
    
    let post: any Post1Providing
    
    var body: some View {
        content
            .contentShape(.rect)
            .quickSwipes(post.swipeActions(behavior: tilePosts ? .tile : .standard))
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
