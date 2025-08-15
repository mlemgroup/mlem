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
    
    @Setting(\.post_size) var postSize
    @Setting(\.feed_showRead) var showRead
    @Setting(\.tip_feedWelcomePrompt) var showWelcomePrompt
    @Setting(\.behavior_internetSpeed) var internetSpeed
    @Setting(\.links_embedLoops) var embedLoops
    
    @AppStorage("lastTestFlightUpdate") var lastTestFlightUpdate: URL?

    @ObservationIgnored @Dependency(\.persistenceRepository) private var persistenceRepository
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
            if AccountsTracker.main.isEmpty, showWelcomePrompt, !appState.firstApi.willSendToken {
                FeedWelcomeView()
                    .padding([.horizontal, .bottom], Constants.main.standardSpacing)
            }
            if Bundle.main.isTestFlight, let testflightUrl = backendClient.testflightUpdate, lastTestFlightUpdate != testflightUrl {
                UpdateBannerView(url: testflightUrl)
                    .padding([.horizontal, .bottom], Constants.main.standardSpacing)
            }
            if let savedFeedLoader {
                PersonContentGridView(feedLoader: savedFeedLoader, contentType: .constant(.all))
            }
        }
        .animation(.snappy, value: backendClient.testflightUpdate != lastTestFlightUpdate)
    }
}

private struct FeedSelectionTitleModifier: ViewModifier {
    let feedOptions: [FeedSelection]
    let shouldScrollToTop: Bool
    @Binding var feedSelection: FeedSelection
    @Binding var scrollToTopTrigger: Bool
    
    @State var isAtTop: Bool = false
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                if !isAtTop {
                    ToolbarTitleMenu {
                        FeedSelectionMenuView(
                            feedOptions: feedOptions,
                            shouldScrollToTop: shouldScrollToTop,
                            feedSelection: $feedSelection,
                            scrollToTopTrigger: $scrollToTopTrigger
                        )
                    }
                }
            }
            .isAtTopSubscriber(isAtTop: $isAtTop)
    }
}

private struct FeedSelectionMenuView: View {
    let feedOptions: [FeedSelection]
    let shouldScrollToTop: Bool
    @Binding var feedSelection: FeedSelection
    @Binding var scrollToTopTrigger: Bool
    
    var body: some View {
        ForEach(feedOptions, id: \.self) { feed in
            Button(
                String(localized: feed.description.label),
                icon: feed.description.icon
            ) {
                if shouldScrollToTop {
                    scrollToTopTrigger.toggle()
                    // delay feed switch to allow scroll to complete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        feedSelection = feed
                    }
                } else {
                    feedSelection = feed
                }
            }
            .symbolVariant(feedSelection == feed ? .fill : .none)
        }
    }
}

#if DEBUG
    #Preview(traits: .sampleEnvironment(api: .realistic)) {
        FeedsView()
            .previewNavigationStack(backButtonLabel: "Feeds")
            .previewTabBar(selected: .feeds)
    }
#endif
