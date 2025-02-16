//
//  View+OutdatedFeedPopup.swift
//  Mlem
//
//  Created by Sjmarf on 03/08/2024.
//

import MlemMiddleware
import SwiftUI

private struct RefreshingFeedLoaderModifier: ViewModifier {
    @Environment(AppState.self) var appState
    @Environment(FiltersTracker.self) var filtersTracker
    
    let feedLoader: any FeedLoading
    
    let canShowPopup: Bool
    
    init(feedLoader: any FeedLoading, showPopup canShowPopup: Bool) {
        self.feedLoader = feedLoader
        self.canShowPopup = canShowPopup
    }
    
    @State var showRefreshPopup: Bool = false
    
    func body(content: Content) -> some View {
        content
            .refreshable {
                await refresh(feedLoader: feedLoader, appState: appState, filtersTracker: filtersTracker)
            }
            .preference(key: FeedPopupPreferenceKey.self, value: showRefreshPopup)
            .onChange(of: apiChangeHash) {
                if let newApi = feedLoader.items.first?.api {
                    showRefreshPopup = canShowPopup && (newApi !== appState.firstApi && feedLoader.loadingState != .loading)
                } else {
                    showRefreshPopup = false
                }
            }
            .onChange(of: filtersTracker.changeHash) {
                if feedLoader.items.count > 0 {
                    showRefreshPopup = true
                }
            }
    }
    
    var apiChangeHash: Int {
        var hasher = Hasher()
        hasher.combine(canShowPopup)
        hasher.combine(appState.firstApi)
        hasher.combine(feedLoader.loadingState)
        hasher.combine(feedLoader.items.first?.api)
        return hasher.finalize()
    }
}

private struct OutdatedFeedPopupModifier: ViewModifier {
    @Environment(AppState.self) var appState
    @Environment(FiltersTracker.self) var filtersTracker

    let feedLoader: (any FeedLoading)?
    @State var showRefreshPopup: Bool = false
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                RefreshPopupView("Feed is outdated", isPresented: $showRefreshPopup) {
                    Task {
                        if let feedLoader {
                            await refresh(feedLoader: feedLoader, appState: appState, filtersTracker: filtersTracker)
                        }
                    }
                }
            }
            .onPreferenceChange(FeedPopupPreferenceKey.self) { value in
                showRefreshPopup = value
            }
    }
}

private func refresh(feedLoader: any FeedLoading, appState: AppState, filtersTracker: FiltersTracker) async {
    do {
        await feedLoader.changeApi(to: appState.firstApi, context: filtersTracker.filterContext)
        
        if let feedLoader = feedLoader as? CorePostFeedLoader {
            if try await appState.firstApi.version < feedLoader.sortType.minimumVersion {
                try await feedLoader.changeSortType(to: appState.initialFeedSortType, forceRefresh: true)
                return
            }
        }
        try await feedLoader.refresh(clearBeforeRefresh: true)
    } catch {
        handleError(error)
    }
}

private struct FeedPopupPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

extension View {
    func refreshing(feedLoader: any FeedLoading, showPopup: Bool = true) -> some View {
        modifier(RefreshingFeedLoaderModifier(feedLoader: feedLoader, showPopup: showPopup))
    }
    
    func outdatedFeedPopup(feedLoader: (any FeedLoading)?) -> some View {
        modifier(OutdatedFeedPopupModifier(feedLoader: feedLoader))
    }
}
