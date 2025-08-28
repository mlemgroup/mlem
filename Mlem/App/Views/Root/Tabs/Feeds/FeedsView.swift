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
    @State var scrollToTopTrigger: Bool = false
    @State var initialListingType: ListingType?
    
    var feedOptions: [ListingType] {
        ListingType.cases(for: appState.firstAccount.accountType, api: appState.firstApi)
    }
    
    init(listingType: ListingType? = nil) {
        _initialListingType = .init(initialValue: listingType)
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
                    feedLoader: postFeedLoader,
                    scrollToTopTrigger: $scrollToTopTrigger
                )
            )
            .toolbar {
                // SwiftUI complains if both this and the menu are in the same toolbar
                if let postFeedLoader {
                    FeedSortPicker(feedLoader: postFeedLoader, showTopTimescaleInIcon: true)
                }
            }
            .conditionalNavigationTitle((postFeedLoader?.feedType.label ?? nil).map(String.init(localized:)) ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: showRead) {
                scrollToTopTrigger.toggle()
            }
            .onChange(of: appState.firstApi, initial: false) {
                // ensure we always are showing an appropriate feed
                if let postFeedLoader {
                    Task {
                        if !ListingType.cases(for: appState.firstAccount.accountType, api: appState.firstApi).contains(postFeedLoader.feedType) {
                            try await postFeedLoader.changeSortType(to: appState.initialFeedSortType)
                            let newFeedSelection: ListingType =
                                appState.firstAccount.accountType == .guest ? .all : .subscribed
                            if newFeedSelection != postFeedLoader.feedType {
                                await postFeedLoader.changeApi(to: appState.firstApi, context: filtersTracker.filterContext)
                            }
                            try await postFeedLoader.changeFeedType(to: newFeedSelection)
                        }
                    }
                }
            }
            .task { await setupFeedLoader() }
            .outdatedFeedPopup(feedLoader: postFeedLoader)
            .environment(\.feedContext, postFeedLoader?.feedType.feedContext)
    }
    
    @ViewBuilder
    var content: some View {
        ZStack {
            if let postFeedLoader {
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
                        PostGridView(postFeedLoader: postFeedLoader)
                    } header: {
                        Menu {
                            FeedSelectionMenuView(
                                feedOptions: feedOptions,
                                shouldScrollToTop: false,
                                feedLoader: postFeedLoader,
                                scrollToTopTrigger: $scrollToTopTrigger
                            )
                        } label: {
                            FeedHeaderView(feedDescription: postFeedLoader.feedType.description, dropdownStyle: .enabled(showBadge: false))
                                .padding(.bottom, Constants.main.standardSpacing)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .animation(.snappy, value: backendClient.testflightUpdate != lastTestFlightUpdate)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.themedGroupedBackground)
            }
        }
    }
    
    @MainActor
    func setupFeedLoader() async {
        print("Set up feed loader")

        guard postFeedLoader == nil else { return }

        @Setting(\.behavior_internetSpeed) var internetSpeed
        @Setting(\.feed_showRead) var showReadPosts
        @Setting(\.feed_default) var defaultFeed
        
        var listingType: ListingType

        do {
            if let initialListingType {
                listingType = initialListingType
            } else if try await appState.firstApi.supports(.listingType(defaultFeed)) {
                listingType = defaultFeed
            } else {
                listingType = .subscribed
            }

            // fallback to local if using guest account and selection requires authenticated account
            if !(AppState.main.firstAccount is UserAccount),
               !ListingType.guestCases.contains(listingType) {
                listingType = .local
            }

            postFeedLoader = try await .init(
                pageSize: internetSpeed.pageSize,
                sortType: appState.initialFeedSortType,
                showReadPosts: showReadPosts,
                filterContext: filtersTracker.filterContext,
                prefetchingConfiguration: .forPostSize(postSize),
                urlCache: Constants.main.urlCache,
                api: appState.firstApi,
                feedType: listingType
            )
        } catch {
            handleError(error)
        }
    }
}

private struct FeedSelectionTitleModifier: ViewModifier {
    let feedOptions: [ListingType]
    let shouldScrollToTop: Bool
    var feedLoader: AggregatePostFeedLoader?
    @Binding var scrollToTopTrigger: Bool
    
    @State var isAtTop: Bool = false
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                if !isAtTop, let feedLoader {
                    ToolbarTitleMenu {
                        FeedSelectionMenuView(
                            feedOptions: feedOptions,
                            shouldScrollToTop: shouldScrollToTop,
                            feedLoader: feedLoader,
                            scrollToTopTrigger: $scrollToTopTrigger
                        )
                    }
                }
            }
            .isAtTopSubscriber(isAtTop: $isAtTop)
    }
}

private struct FeedSelectionMenuView: View {
    let feedOptions: [ListingType]
    let shouldScrollToTop: Bool
    @Binding var feedSelection: ListingType
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

extension FeedSelectionMenuView {
    init(
        feedOptions: [ListingType],
        shouldScrollToTop: Bool,
        feedLoader: AggregatePostFeedLoader,
        scrollToTopTrigger: Binding<Bool>
    ) {
        self._feedSelection = .init(get: {
            feedLoader.feedType
        }, set: { newValue in
            Task { @MainActor in
                do {
                    try await feedLoader.changeFeedType(to: newValue)
                } catch {
                    handleError(error)
                }
            }
        })

        self.feedOptions = feedOptions
        self.shouldScrollToTop = shouldScrollToTop
        self._scrollToTopTrigger = scrollToTopTrigger
    }
}

#if DEBUG
    #Preview(traits: .sampleEnvironment(api: .realistic)) {
        FeedsView()
            .previewNavigationStack(backButtonLabel: "Feeds")
            .previewTabBar(selected: .feeds)
    }
#endif
