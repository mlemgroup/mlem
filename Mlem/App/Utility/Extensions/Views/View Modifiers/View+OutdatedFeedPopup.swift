//
//  View+OutdatedFeedPopup.swift
//  Mlem
//
//  Created by Sjmarf on 03/08/2024.
//

import MlemMiddleware
import SwiftUI

private struct OutdatedFeedPopupModifier: ViewModifier {
    @Environment(AppState.self) var appState
    @Environment(FiltersTracker.self) var filtersTracker
    
    let feedLoader: (any FeedLoading)?
    
    let canShowPopup: Bool
    let onManualRefresh: (() -> Void)?

    init(feedLoader: (any FeedLoading)?, showPopup canShowPopup: Bool, onManualRefresh: (() -> Void)? = nil) {
        self.feedLoader = feedLoader
        self.canShowPopup = canShowPopup
        self.onManualRefresh = onManualRefresh
    }
    
    @State var showRefreshPopup: Bool = false
    
    func body(content: Content) -> some View {
        content
            .refreshable(isEnabled: feedLoader != nil) {
                if let feedLoader {
                    onManualRefresh?()
                    await refresh(feedLoader, clearBeforeRefresh: false)
                }
            }
            .onChange(of: apiChangeHash) {
                if let feedLoader {
                    if let newApi = feedLoader.items.first?.api {
                        showRefreshPopup = canShowPopup && (
                            newApi !== appState.firstApi && ![.loading, .initial].contains(feedLoader.loadingState)
                        )
                    } else {
                        showRefreshPopup = false
                    }
                }
            }
            .onChange(of: filtersTracker.changeHash) {
                if let feedLoader {
                    if feedLoader.items.count > 0 {
                        showRefreshPopup = true
                    }
                }
            }
            .overlay(alignment: .bottom) {
                RefreshPopupView("Feed is outdated", isPresented: $showRefreshPopup) {
                    Task {
                        if let feedLoader {
                            await refresh(feedLoader, clearBeforeRefresh: true)
                        }
                    }
                }
            }
    }
    
    var apiChangeHash: Int {
        var hasher = Hasher()
        hasher.combine(canShowPopup)
        hasher.combine(appState.firstApi)
        hasher.combine(feedLoader?.loadingState)
        hasher.combine(feedLoader?.items.first?.api)
        return hasher.finalize()
    }
    
    func refresh(_ feedLoader: any FeedLoading, clearBeforeRefresh: Bool) async {
        do {
            showRefreshPopup = false
            await feedLoader.changeApi(to: appState.firstApi, context: filtersTracker.filterContext)
            
            // This duplication isn't ideal, but it works for now
            if let feedLoader = feedLoader as? AggregatePostFeedLoader {
                if try await !appState.firstApi.supports(.postSortType(feedLoader.sortType)) {
                    try await feedLoader.changeSortType(to: appState.initialFeedSortType, forceRefresh: true)
                    return
                }
            }
            if let feedLoader = feedLoader as? CommunityPostFeedLoader {
                if try await !appState.firstApi.supports(.postSortType(feedLoader.sortType)) {
                    try await feedLoader.changeSortType(to: appState.initialFeedSortType, forceRefresh: true)
                    return
                }
            }
            
            try await feedLoader.refresh(clearBeforeRefresh: clearBeforeRefresh)
        } catch {
            handleError(error)
        }
    }
}

extension View {
    func outdatedFeedPopup(feedLoader: (any FeedLoading)?, showPopup: Bool = true, onManualRefresh: (() -> Void)? = nil) -> some View {
        modifier(OutdatedFeedPopupModifier(feedLoader: feedLoader, showPopup: showPopup, onManualRefresh: onManualRefresh))
    }
}
