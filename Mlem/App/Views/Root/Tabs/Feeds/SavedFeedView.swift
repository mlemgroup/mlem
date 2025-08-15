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
    
    @State var savedFeedLoader: PersonContentFeedLoader?
    
    @State var scrollToTopTrigger: Bool = false
    
    init(feedSelection: FeedSelection? = nil) {
        // need to grab some stuff from app storage to initialize with
        @Setting(\.behavior_internetSpeed) var internetSpeed
        @Setting(\.post_size) var postSize
        
        if let firstUser = AppState.main.firstAccount as? UserAccount {
            _savedFeedLoader = .init(wrappedValue: .init(
                api: AppState.main.firstApi,
                pageSize: internetSpeed.pageSize,
                userId: firstUser.id,
                sortType: .new,
                savedOnly: true,
                prefetchingConfiguration: .forPostSize(postSize)
            ))
        }
    }
    
    var body: some View {
        content
            .background(ThemedColor.themedGroupedBackground)
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
            if let savedFeedLoader {
                PersonContentGridView(feedLoader: savedFeedLoader, contentType: .constant(.all))
            }
        }
    }
}
