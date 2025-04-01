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
    
    @Setting(\.postSize) var postSize
    @Setting(\.showReadInFeed) var showRead
    @Setting(\.showFeedWelcomePrompt) var showWelcomePrompt
    @Setting(\.internetSpeed) var internetSpeed
    @Setting(\.embedLoops) var embedLoops
    
    @AppStorage("lastBuildNumber") var lastBuildNumber: String?

    @ObservationIgnored @Dependency(\.persistenceRepository) private var persistenceRepository
    
    @State var postFeedLoader: AggregatePostFeedLoader?
    @State var savedFeedLoader: PersonContentFeedLoader?
    
    @State var feedSelection: FeedSelection {
        didSet {
            guard oldValue != feedSelection else { return }
            Task {
                do {
                    // clear whichever loader is now inactive and refresh/update active loader
                    if feedSelection == .saved {
                        await postFeedLoader?.clear()
                        try await savedFeedLoader?.refresh(clearBeforeRefresh: true)
                    } else {
                        await savedFeedLoader?.clear()
                        try await postFeedLoader?.changeFeedType(to: feedSelection.associatedApiType)
                    }
                } catch {
                    handleError(error)
                }
            }
        }
    }

    @State var isAtTop: Bool = true
    @State var scrollToTopTrigger: Bool = false
    
    var feedOptions: [FeedSelection] {
        FeedSelection.cases(for: appState.firstAccount.accountType)
    }
    
    init(feedSelection: FeedSelection? = nil) {
        // need to grab some stuff from app storage to initialize with
        @Setting(\.internetSpeed) var internetSpeed
        @Setting(\.showReadInFeed) var showReadPosts
        @Setting(\.defaultPostSort) var defaultSort
        @Setting(\.postSize) var postSize
        @Setting(\.defaultFeed) var defaultFeed
        
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
            .background(ThemedColor.themedGroupedBackground.ignoresSafeArea())
            .scrollContentBackground(.hidden)
            .toolbar {
                if !isAtTop {
                    ToolbarTitleMenu {
                        feedSelectionMenu(scroll: true)
                    }
                }
            }
            .toolbar {
                // SwiftUI complains if both this and the menu are in the same toolbar
                if let postFeedLoader, feedSelection != .saved {
                    FeedSortPicker(feedLoader: postFeedLoader, showTopTimescaleInIcon: true)
                }
            }
            .navigationTitle(isAtTop ? "" : String(localized: feedSelection.description.label))
            .navigationBarTitleDisplayMode(.inline)
            .isAtTopSubscriber(isAtTop: $isAtTop)
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
            .outdatedFeedPopup(feedLoader: {
                if feedSelection == .saved, let savedFeedLoader {
                    return savedFeedLoader
                }
                return postFeedLoader
            }())
            .environment(\.feedContext, feedSelection.feedContext)
    }
    
    @ViewBuilder
    var content: some View {
        FancyScrollView(scrollToTopTrigger: $scrollToTopTrigger) {
            Section {
                if AccountsTracker.main.isEmpty, showWelcomePrompt, !appState.firstApi.willSendToken {
                    FeedWelcomeView()
                        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
                }
                if Bundle.main.isTestFlight, lastBuildNumber != Bundle.main.buildVersionNumber {
                    UpdateBannerView()
                        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
                }
                if let savedFeedLoader, feedSelection == .saved {
                    PersonContentGridView(feedLoader: savedFeedLoader, contentType: .constant(.all))
                } else if let postFeedLoader {
                    PostGridView(postFeedLoader: postFeedLoader)
                }
            } header: {
                Menu {
                    feedSelectionMenu(scroll: false)
                } label: {
                    FeedHeaderView(feedDescription: feedSelection.description, dropdownStyle: .enabled(showBadge: false))
                        .padding(.bottom, Constants.main.standardSpacing)
                }
                .buttonStyle(.plain)
            }
        }
        .animation(.snappy, value: lastBuildNumber != Bundle.main.buildVersionNumber)
    }
    
    @ViewBuilder
    func feedSelectionMenu(scroll: Bool) -> some View {
        ForEach(feedOptions, id: \.self) { feed in
            Button(
                String(localized: feed.description.label),
                systemImage: feedSelection == feed ? feed.description.iconNameFill : feed.description.iconName
            ) {
                if scroll {
                    scrollToTopTrigger.toggle()
                    // delay feed switch to allow scroll to complete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        feedSelection = feed
                    }
                } else {
                    feedSelection = feed
                }
            }
        }
    }
    
    @MainActor
    func setupFeedLoader() async {
        guard postFeedLoader == nil else { return }

        @Setting(\.internetSpeed) var internetSpeed
        @Setting(\.showReadInFeed) var showReadPosts
        
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

#if DEBUG
    #Preview(traits: .sampleEnvironment(api: .realistic)) {
        FeedsView()
            .previewNavigationStack(backButtonLabel: "Feeds")
            .previewTabBar(selected: .feeds)
    }
#endif
