//
//  FeedsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-07.
//

import Dependencies
import Foundation
import MlemMiddleware
import SwiftUI
import Theming

struct FeedsView: View {
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
    
    @State var postFeedLoader: AggregatePostFeedLoader?
    
    @State var feedSelection: FeedSelection

    @State var scrollToTopTrigger: Bool = false
    
    var feedOptions: [FeedSelection] {
        FeedSelection.cases(for: appState.firstAccount.accountType)
    }
    
    init(feedSelection: FeedSelection? = nil) {
        @Setting(\.feed_default) var defaultFeed
        
        @Dependency(\.persistenceRepository) var persistenceRepository
        
        var initialFeedSelection: FeedSelection
        if let feedSelection {
            initialFeedSelection = feedSelection
        } else {
            initialFeedSelection = defaultFeed
        }
        
        // fallback to local if using guest account and selection requires authenticated account
        if !(AppState.main.firstAccount is UserAccount), !FeedSelection.guestCases.contains(initialFeedSelection) {
            initialFeedSelection = .local
        }
        
        _feedSelection = .init(initialValue: initialFeedSelection)
    }
    
    var body: some View {
        content
            .background(ThemedColor.themedGroupedBackground)
            .themedGroupedBackground()
            .scrollContentBackground(.hidden)
            .modifier(
                FeedSelectionTitleModifier(
                    feedOptions: feedOptions,
                    shouldScrollToTop: true,
                    feedSelection: $feedSelection,
                    scrollToTopTrigger: $scrollToTopTrigger
                )
            )
            .toolbar {
                // SwiftUI complains if both this and the menu are in the same toolbar
                if let postFeedLoader {
                    FeedSortPicker(feedLoader: postFeedLoader, showTopTimescaleInIcon: true)
                }
            }
            .conditionalNavigationTitle(String(localized: feedSelection.description.label))
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: showRead) {
                scrollToTopTrigger.toggle()
            }
            .onChange(of: appState.firstApi, initial: false) {
                // ensure we always are showing an appropriate feed
                Task {
                    if !FeedSelection.cases(for: appState.firstAccount.accountType).contains(feedSelection) {
                        try await postFeedLoader?.changeSortType(to: appState.initialFeedSortType)
                        let newFeedSelection: FeedSelection = appState.firstAccount.accountType == .guest ? .all : .subscribed
                        if newFeedSelection != feedSelection {
                            await postFeedLoader?.changeApi(to: appState.firstApi, context: filtersTracker.filterContext)
                        }
                        feedSelection = newFeedSelection
                    }
                }
            }
            .task { await setupFeedLoader() }
            .outdatedFeedPopup(feedLoader: postFeedLoader)
            .environment(\.feedContext, feedSelection.feedContext)
            .onChange(of: feedSelection) { oldValue, _ in
                guard oldValue != feedSelection else { return }
                Task {
                    do {
                        try await postFeedLoader?.changeFeedType(to: feedSelection.associatedApiType)
                    } catch {
                        handleError(error)
                    }
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        FancyScrollView(scrollToTopTrigger: $scrollToTopTrigger) {
            Section {
                if AccountsTracker.main.isEmpty, showWelcomePrompt, !appState.firstApi.willSendToken {
                    FeedWelcomeView()
                        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
                }
                if Bundle.main.isTestFlight, let testflightUrl = backendClient.testflightUpdate, lastTestFlightUpdate != testflightUrl {
                    UpdateBannerView(url: testflightUrl)
                        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
                }
                if let postFeedLoader {
                    PostGridView(postFeedLoader: postFeedLoader)
                }
            } header: {
                Menu {
                    FeedSelectionMenuView(
                        feedOptions: feedOptions,
                        shouldScrollToTop: false,
                        feedSelection: $feedSelection,
                        scrollToTopTrigger: $scrollToTopTrigger
                    )
                } label: {
                    FeedHeaderView(feedDescription: feedSelection.description, dropdownStyle: .enabled(showBadge: false))
                        .padding(.bottom, Constants.main.standardSpacing)
                }
                .buttonStyle(.plain)
            }
        }
        .animation(.snappy, value: backendClient.testflightUpdate != lastTestFlightUpdate)
    }
    
    @MainActor
    func setupFeedLoader() async {
        guard postFeedLoader == nil else { return }

        @Setting(\.behavior_internetSpeed) var internetSpeed
        @Setting(\.feed_showRead) var showReadPosts
        
        do {
            postFeedLoader = try await .init(
                pageSize: internetSpeed.pageSize,
                sortType: appState.initialFeedSortType,
                showReadPosts: showReadPosts,
                filterContext: filtersTracker.filterContext,
                prefetchingConfiguration: .forPostSize(postSize),
                urlCache: Constants.main.urlCache,
                api: appState.firstApi,
                feedType: feedSelection.associatedApiType
            )
        } catch {
            handleError(error)
        }
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
