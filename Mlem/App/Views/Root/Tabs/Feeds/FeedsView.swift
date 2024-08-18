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

struct FeedsView: View {
    @Setting(\.postSize) var postSize
    @Setting(\.showReadInFeed) var showRead
    
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
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
                        savedFeedLoader?.clear()
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
        appState.firstAccount is UserAccount ? FeedSelection.allCases : FeedSelection.guestCases
    }
    
    init(feedSelection: FeedSelection = .subscribed) {
        // need to grab some stuff from app storage to initialize with
        @Setting(\.internetSpeed) var internetSpeed
        @Setting(\.showReadInFeed) var showReadPosts
        @Setting(\.defaultPostSort) var defaultSort
        @Setting(\.postSize) var postSize
        
        @Dependency(\.persistenceRepository) var persistenceRepository
        
        let initialFeedSelection: FeedSelection = feedSelection
        _feedSelection = .init(initialValue: initialFeedSelection)
        
        if let firstUser = AppState.main.firstAccount as? UserAccount {
            _savedFeedLoader = .init(wrappedValue: .init(
                api: AppState.main.firstApi,
                userId: firstUser.id,
                sortType: .new,
                savedOnly: true,
                prefetchingConfiguration: .forPostSize(postSize)
            ))
        }
    }
    
    var body: some View {
        content
            .background(postSize.tiled ? palette.groupedBackground : palette.background)
            .navigationBarTitleDisplayMode(.inline)
            // .loadFeed(savedFeedLoader)
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
                    FeedSortPicker(feedLoader: postFeedLoader)
                }
            }
            .navigationTitle(isAtTop ? "" : String(localized: feedSelection.description.label))
            .isAtTopSubscriber(isAtTop: $isAtTop)
            .onChange(of: showRead) {
                scrollToTopTrigger.toggle()
            }
            .onChange(of: appState.firstApi, initial: false) {
                postFeedLoader?.api = appState.firstApi
                
                if appState.firstApi.canInteract, let firstUser = appState.firstAccount as? UserAccount {
                    if let savedFeedLoader {
                        savedFeedLoader.switchUser(api: appState.firstApi, userId: firstUser.id)
                    } else {
                        savedFeedLoader = .init(
                            api: appState.firstApi,
                            userId: firstUser.id,
                            sortType: .new,
                            savedOnly: true,
                            prefetchingConfiguration: .forPostSize(postSize)
                        )
                    }
                } else {
                    savedFeedLoader = nil

                    // ensure we only show non-authenticated feeds to non-authenticated users
                    Task {
                        if !FeedSelection.guestCases.contains(feedSelection) {
                            postFeedLoader?.sortType = try await appState.initialFeedSortType
                            feedSelection = .all
                        }
                    }
                }
            }
            .task(setupFeedLoader)
            .outdatedFeedPopup(feedLoader: {
                if feedSelection == .saved, let savedFeedLoader {
                    return savedFeedLoader
                }
                return postFeedLoader
            }())
    }
    
    @ViewBuilder
    var content: some View {
        FancyScrollView(scrollToTopTrigger: $scrollToTopTrigger) {
            Section {
                if !postSize.tiled { Divider() }
                
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
            } footer: {
                Group {
                    switch postFeedLoader?.loadingState {
                    case .loading, nil:
                        Text("Loading...")
                    case .done:
                        Text("Done")
                    case .idle:
                        Text("Idle")
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
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
    
    @Sendable
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
                filteredKeywords: [],
                prefetchingConfiguration: .forPostSize(postSize),
                urlCache: Constants.main.urlCache,
                api: AppState.main.firstApi,
                feedType: feedSelection.associatedApiType
            )
        } catch {
            handleError(error)
        }
    }
}
