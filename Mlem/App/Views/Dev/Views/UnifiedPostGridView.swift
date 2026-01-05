//
//  UnifiedPostGridView.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-05.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct UnifiedPostGridView: View {
    let postFeedLoader: UnifiedCorePostFeedLoader
    
    let alwaysShowRead: Bool

    init(postFeedLoader: UnifiedCorePostFeedLoader, alwaysShowRead: Bool = false) {
        self.postFeedLoader = postFeedLoader
        self.alwaysShowRead = alwaysShowRead
    }
    
    var body: some View {
        content
            .loadFeed(postFeedLoader)
    }
    
    var content: some View {
        LazyVStack {
            ForEach(Array(postFeedLoader.items.enumerated()), id: \.element.actorId) { _, post in
                NavigationLink(.devPost(post)) {
                    DevFeedPostView(post: post)
                }
                Divider()
            }
        }
    }
}
