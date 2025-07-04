//
//  View+LoadFeed.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-07-05.
//

import Foundation
import MlemMiddleware
import SwiftUI

private struct LoadFeed: ViewModifier {
    @Setting(\.post_size) var postSize
    
    let feedLoader: (any FeedLoading)?
    let shouldLoad: Bool
    
    func body(content: Content) -> some View {
        content
            .onChange(of: onChangeHash, initial: true) {
                if let feedLoader, feedLoader.items.isEmpty, shouldLoad {
                    // wrapping this in a Task instead of using .task prevents cancellation errors from the parent view de-rendering
                    Task {
                        do {
                            try await feedLoader.loadMoreItems()
                        } catch {
                            handleError(error)
                        }
                    }
                }
            }
            .onChange(of: postSize) {
                (feedLoader as? CorePostFeedLoader)?.setPrefetchingConfiguration(.forPostSize(postSize))
            }
    }
    
    var onChangeHash: Int {
        var hasher = Hasher()
        hasher.combine(feedLoader == nil)
        hasher.combine(shouldLoad)
        return hasher.finalize()
    }
}

extension View {
    /// Convenience modifier. Attach to a view to load items from the given FeedLoading on appear if the given FeedLoading has no items
    func loadFeed(_ feedLoader: (any FeedLoading)?, shouldLoad: Bool = true) -> some View {
        modifier(LoadFeed(feedLoader: feedLoader, shouldLoad: shouldLoad))
    }
}
