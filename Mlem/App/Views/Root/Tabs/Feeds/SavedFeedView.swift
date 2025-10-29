//
//  SavedFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-07.
//

import Dependencies
import Foundation
import MlemMiddleware
import SwiftUI
import Theming

struct SavedFeedView: View {
    @Environment(AppState.self) var appState
    @Environment(FiltersTracker.self) var filtersTracker
    @Environment(BackendClient.self) var backendClient
    
    @State var savedFeedLoader: DualSourceMixedFeedLoader
    
    @State var scrollToTopTrigger: Bool = false
    
    init() {
        // need to grab some stuff from app storage to initialize with
        @Setting(\.behavior_internetSpeed) var internetSpeed
        @Setting(\.post_size) var postSize

        let savedFeedLoaders = DualSourceMixedFeedLoader.setup(
            api: AppState.main.firstApi,
            pageSize: internetSpeed.pageSize,
            sortType: .new
        )
        
        self._savedFeedLoader = .init(wrappedValue: savedFeedLoaders.savedFeedLoader)
    }
    
    var body: some View {
        content
            .themedGroupedBackground()
            .scrollContentBackground(.hidden)
            .conditionalNavigationTitle("Saved")
            .navigationBarTitleDisplayMode(.inline)
            .outdatedFeedPopup(feedLoader: savedFeedLoader)
            .environment(\.feedContext, .saved)
    }
    
    @ViewBuilder
    var content: some View {
        FancyScrollView(scrollToTopTrigger: $scrollToTopTrigger) {
            PersonContentGridView(feedLoader: .dualSourceMixed(savedFeedLoader))
        }
    }
}
