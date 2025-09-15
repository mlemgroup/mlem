//
//  UpvotedFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-09-15.
//

import SwiftUI
import MlemMiddleware

struct UpvotedFeedView: View {
    @State var postFeedLoader: AggregatePostFeedLoader?
    @Environment(FiltersTracker.self) var filtersTracker
    
    @State var scrollToTopTrigger: Bool = false
    
    var body: some View {
        content
            .task { await setupFeedLoader() }
            .background(.themedGroupedBackground)
            .themedGroupedBackground()
            .scrollContentBackground(.hidden)
            .conditionalNavigationTitle("Upvoted")
            .navigationBarTitleDisplayMode(.inline)
            .outdatedFeedPopup(feedLoader: postFeedLoader)
    }
    
    var content: some View {
        FancyScrollView(scrollToTopTrigger: $scrollToTopTrigger) {
            if let postFeedLoader {
                PostGridView(postFeedLoader: postFeedLoader, alwaysShowRead: true)
            }
        }
    }
    
    @MainActor
    func setupFeedLoader() async {
        guard postFeedLoader == nil else { return }
        
        @Setting(\.behavior_internetSpeed) var internetSpeed
        @Setting(\.post_size) var postSize
        
        if let firstUser = AppState.main.firstAccount as? UserAccount {
            postFeedLoader = .init(
                pageSize: internetSpeed.pageSize,
                sortType: .new,
                showReadPosts: true,
                filterContext: filtersTracker.filterContext,
                prefetchingConfiguration: .forPostSize(postSize),
                urlCache: Constants.main.urlCache,
                api: firstUser.api,
                feedType: .all,
                contentFilter: .upvoted)
        }
    }
}
