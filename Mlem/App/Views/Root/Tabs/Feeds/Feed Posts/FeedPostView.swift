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
        }
    }
    
    private struct Content: View {
        @AppStorage("post.size") var size: PostSize = .large
        
        let post: any Post1Providing
        
        init(for post: any Post1Providing) {
            self.post = post
        }
        
        var body: some View {
            switch size {
            case .compact:
                CompactPost(post: post)
            case .tile:
                CardPost(post: post)
            case .headline:
                HeadlinePost(post: post)
            case .large:
                LargePost(post: post)
            }
        }
    }
}
