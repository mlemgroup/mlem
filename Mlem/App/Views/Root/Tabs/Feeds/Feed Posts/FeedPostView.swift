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
