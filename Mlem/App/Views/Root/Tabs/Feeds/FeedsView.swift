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
    
    @State var listingType: ListingType

    @State var scrollToTopTrigger: Bool = false
    
    var feedOptions: [ListingType] {
        ListingType.cases(for: appState.firstAccount.accountType)
    }
    
    init(listingType: ListingType? = nil) {
        @Setting(\.feed_default) var defaultFeed
        
        @Dependency(\.persistenceRepository) var persistenceRepository
        
        var initialFeedSelection: ListingType
        if let listingType {
            initialFeedSelection = listingType
        } else {
            initialFeedSelection = defaultFeed
        }
        
        // fallback to local if using guest account and selection requires authenticated account
        if !(AppState.main.firstAccount is UserAccount), !ListingType.guestCases.contains(initialFeedSelection) {
            initialFeedSelection = .local
        }
        
        _listingType = .init(initialValue: initialFeedSelection)
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
                    feedSelection: $listingType,
                    scrollToTopTrigger: $scrollToTopTrigger
                )
            )
            .toolbar {
                // SwiftUI complains if both this and the menu are in the same toolbar
                if let postFeedLoader {
                    FeedSortPicker(feedLoader: postFeedLoader, showTopTimescaleInIcon: true)
                }
            }
            .conditionalNavigationTitle(String(localized: listingType.label))
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: showRead) {
                scrollToTopTrigger.toggle()
            }
            .onChange(of: appState.firstApi, initial: false) {
                // ensure we always are showing an appropriate feed
                Task {
                    if !ListingType.cases(for: appState.firstAccount.accountType).contains(listingType) {
                        try await postFeedLoader?.changeSortType(to: appState.initialFeedSortType)
                        let newFeedSelection: ListingType = appState.firstAccount.accountType == .guest ? .all : .subscribed
                        if newFeedSelection != listingType {
                            await postFeedLoader?.changeApi(to: appState.firstApi, context: filtersTracker.filterContext)
                        }
                        listingType = newFeedSelection
                    }
                }
            }
            .task { await setupFeedLoader() }
            .outdatedFeedPopup(feedLoader: postFeedLoader)
            .environment(\.feedContext, listingType.feedContext)
            .onChange(of: listingType) { oldValue, _ in
                guard oldValue != listingType else { return }
                Task {
                    do {
                        try await postFeedLoader?.changeFeedType(to: listingType)
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
                        feedSelection: $listingType,
                        scrollToTopTrigger: $scrollToTopTrigger
                    )
                } label: {
                    FeedHeaderView(feedDescription: listingType.description, dropdownStyle: .enabled(showBadge: false))
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
    @Binding var feedSelection: ListingType
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

#if DEBUG
    #Preview(traits: .sampleEnvironment(api: .realistic)) {
        FeedsView()
            .previewNavigationStack(backButtonLabel: "Feeds")
            .previewTabBar(selected: .feeds)
    }
#endif
