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
    
    let feedLoader: any FeedLoading
    
    @State var showRefreshPopup: Bool = false
    
    func body(content: Content) -> some View {
        content
            .refreshable {
                do {
                    showRefreshPopup = false
                    try await feedLoader.refresh(clearBeforeRefresh: false)
                } catch {
                    handleError(error)
                }
            }
            .onChange(of: feedLoader.items.first?.api !== appState.firstApi) { _, newValue in
                showRefreshPopup = newValue
            }
            .overlay(alignment: .bottom) {
                RefreshPopupView("Feed is outdated", isPresented: $showRefreshPopup) {
                    Task {
                        do {
                            showRefreshPopup = false
                            try await feedLoader.refresh(clearBeforeRefresh: true)
                        } catch {
                            handleError(error)
                        }
                    }
                }
            }
    }
}

extension View {
    func outdatedFeedPopup(feedLoader: any FeedLoading) -> some View {
        modifier(OutdatedFeedPopupModifier(feedLoader: feedLoader))
    }
}
