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
    @AppStorage("post.size") var size: PostSize = .large
    
    let post: any Post1Providing
    
    var body: some View {
        Group {
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
