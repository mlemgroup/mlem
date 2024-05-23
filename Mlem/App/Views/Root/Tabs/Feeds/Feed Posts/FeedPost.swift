//
//  FeedPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

/// View for rendering posts in feed.
/// This view takes in information like context and AppStorage values and does all the work to figure out which post size to display,
/// whether to show avatars, whether compact post should show username or community, etc.; the sub-views (CompactPost, HeadlinePost, LargePost)
/// are designed to be dumb and straightforward and just take in a bunch of toggles dictating what to display.
struct FeedPost: View {
    @AppStorage("post.size") var size: PostSize = .compact
    
    let post: AnyPost
    
    var body: some View {
        ContentLoader(model: post) { post in
            content(for: post)
                .environment(\.postContext, post)
        }
    }
    
    @ViewBuilder
    func content(for post: any Post1Providing) -> some View {
        switch size {
        case .compact:
            CompactPost(post: post, showUsername: false)
        case .headline:
            HeadlinePost()
        case .large:
            LargePost()
        }
    }
}
