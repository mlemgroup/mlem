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
    @Setting(\.postSize) var postSize
    
    let feedLoader: (any FeedLoading)?
    
    func body(content: Content) -> some View {
        content
            .task {
                if let feedLoader, feedLoader.items.isEmpty, feedLoader.loadingState == .idle {
                    do {
                        try await feedLoader.loadMoreItems()
                    } catch {
                        handleError(error)
                    }
                }
            }
            .onChange(of: postSize) {
                (feedLoader as? CorePostFeedLoader)?.setPrefetchingConfiguration(.forPostSize(postSize))
            }
    }
}

extension View {
    /// Convenience modifier. Attach to a view to load items from the given FeedLoading on appear if the given FeedLoading has no items
    func loadFeed(_ feedLoader: (any FeedLoading)?) -> some View {
        modifier(LoadFeed(feedLoader: feedLoader))
    }
}
