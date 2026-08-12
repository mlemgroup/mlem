//
//  SavedFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-07.
//

import Dependencies
import Foundation
import MlemBackend
import MlemMiddleware
import SwiftUI
import Theming

struct VisitAgainView: View {
    @Environment(AppState.self) var appState
    @Environment(FiltersTracker.self) var filtersTracker
    @Environment(BackendClient.self) var backendClient
    
    let filter: GetContentFilter
    
    @State var mixedFeedLoader: DualSourceMixedFeedLoader
    @State var postsFeedLoader: PostChildFeedLoader
    @State var commentsFeedLoader: CommentChildFeedLoader

    @State var selectedContentType: PersonContentType = .all
    @State var scrollToTopTrigger: Bool = false
    
    init(filter: GetContentFilter) {
        // need to grab some stuff from app storage to initialize with
        @Setting(\.behavior_internetSpeed) var internetSpeed
        @Setting(\.post_size) var postSize

        let feedLoaders = DualSourceMixedFeedLoader.setup(
            api: AppState.main.firstApi,
            pageSize: internetSpeed.pageSize,
            sortType: .new,
            filter: filter
        )
        
        self._mixedFeedLoader = .init(wrappedValue: feedLoaders.parentFeedLoader)
        self._postsFeedLoader = .init(wrappedValue: feedLoaders.postFeedLoader)
        self._commentsFeedLoader = .init(wrappedValue: feedLoaders.commentFeedLoader)
        
        self.filter = filter
        
    }
    
    var body: some View {
        content
            .themedGroupedBackground()
            .scrollContentBackground(.hidden)
            .conditionalNavigationTitle(filter.label)
            .navigationBarTitleDisplayMode(.inline)
            .outdatedFeedPopup(feedLoader: mixedFeedLoader)
            .environment(\.feedContext, .saved)
    }
    
    @ViewBuilder
    var content: some View {
        FancyScrollView(scrollToTopTrigger: $scrollToTopTrigger) {
            BubblePicker(PersonContentType.allCases, selected: $selectedContentType, label: \.label)
            PersonContentGridView(feedLoader: .standard(selectedFeedLoader, contentType: selectedContentType))
        }
    }
    
    var selectedFeedLoader: StandardFeedLoader<PersonContent> {
        switch selectedContentType {
        case .all: mixedFeedLoader
        case .posts: postsFeedLoader
        case .comments: commentsFeedLoader
        }
    }
}
