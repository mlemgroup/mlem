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
    
    let feedLoader: (any FeedLoading)?
    
    @State var showRefreshPopup: Bool = false
    
    func body(content: Content) -> some View {
        content
            .refreshable {
                do {
                    showRefreshPopup = false
                    try await feedLoader?.refresh(clearBeforeRefresh: false)
                } catch {
                    handleError(error)
                }
            }
            .onChange(of: onChangeHash) {
                if let newApi = feedLoader?.items.first?.api {
                    showRefreshPopup = newApi !== appState.firstApi
                }
            }
            .overlay(alignment: .bottom) {
                RefreshPopupView("Feed is outdated", isPresented: $showRefreshPopup) {
                    Task {
                        do {
                            showRefreshPopup = false
                            try await feedLoader?.refresh(clearBeforeRefresh: true)
                        } catch {
                            handleError(error)
                        }
                    }
                }
            }
    }
    
    var onChangeHash: Int {
        var hasher = Hasher()
        hasher.combine(appState.firstApi)
        hasher.combine(feedLoader?.items.first?.api)
        return hasher.finalize()
    }
}

extension View {
    func outdatedFeedPopup(feedLoader: (any FeedLoading)?) -> some View {
        modifier(OutdatedFeedPopupModifier(feedLoader: feedLoader))
    }
}
