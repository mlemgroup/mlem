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
/// The Loader/Content pattern is required to ensure that FeedPostView accurately picks up on changes to `@AppStorage("post.size")`; the raw ContentLoader doesn't evaluate `size` when deciding whether to re-render, so putting content in a simple `@ViewBuilder` function will not properly re-render on settings toggle.
struct FeedPostView: View {
    let post: AnyPost
    
    var body: some View {
        ContentLoader(model: post) { post in
            Content(for: post)
                .environment(\.postContext, post)
                .quickSwipes(leading: [.init(
                    isOn: true,
                    label: "Test",
                    color: .green,
                    icon: Icons.save,
                    swipeIcon1: Icons.save,
                    swipeIcon2: Icons.saveFill
                ) {
                    print("swiped!")
                }])
        }
    }
    
    private struct Content: View {
        @AppStorage("post.size") var size: PostSize = .large
        @AppStorage("beta.tilePosts") var tilePosts: Bool = false
        
        let post: any Post1Providing
        
        init(for post: any Post1Providing) {
            self.post = post
        }
        
        var body: some View {
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
}
