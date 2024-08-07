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
    
    @Environment(\.dismiss) var dismiss
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    @State var postFeedLoader: AggregatePostFeedLoader
    @State var savedFeedLoader: PersonContentFeedLoader?
    @State var feedOptions: [FeedSelection] = FeedSelection.guestCases
    @State var feedSelection: FeedSelection {
        didSet {
            Task {
                do {
                    // clear whichever loader is now inactive and refresh/update active loader
                    if feedSelection == .saved {
                        await postFeedLoader.clear()
                        try await savedFeedLoader?.refresh(clearBeforeRefresh: true)
                    } else {
                        savedFeedLoader?.clear()
                        try await postFeedLoader.changeFeedType(to: feedSelection.associatedApiType)
                    }
                } catch {
                    handleError(error)
                }
            }
        }
    }

    @State var scrollToTopTrigger: Bool = false
    
    enum FeedSelection: CaseIterable {
        case all, local, subscribed, saved
        // TODO: moderated
        
        static var guestCases: [FeedSelection] {
            [.all, .local]
        }
        
        var description: FeedDescription {
            switch self {
            case .all: .all
            case .local: .local
            case .subscribed: .subscribed
            case .saved: .saved
            }
        }
        
        var associatedApiType: ApiListingType {
            switch self {
            case .all: .all
            case .local: .local
            case .subscribed: .subscribed
            case .saved: .all // dummy value
            }
        }
    }
    
    init() {
        // need to grab some stuff from app storage to initialize with
        @Setting(\.internetSpeed) var internetSpeed
        @Setting(\.upvoteOnSave) var upvoteOnSave
        @Setting(\.showReadInFeed) var showReadPosts
        @Setting(\.defaultPostSort) var defaultSort
        
        @Dependency(\.persistenceRepository) var persistenceRepository
        
        let initialFeedSelection: FeedSelection = .subscribed
        _feedSelection = .init(initialValue: initialFeedSelection)
        _postFeedLoader = .init(initialValue: .init(
            pageSize: internetSpeed.pageSize,
            sortType: .new,
            showReadPosts: showReadPosts,
            // Don't load from PersistenceRepository directly here, as we'll be reading from file every time the view is initialized, which can happen frequently
            filteredKeywords: [],
            smallAvatarSize: Constants.main.smallAvatarSize,
            largeAvatarSize: Constants.main.largeAvatarSize,
            urlCache: Constants.main.urlCache,
            api: AppState.main.firstApi,
            feedType: initialFeedSelection.associatedApiType
        ))
        if let firstUser = AppState.main.firstAccount as? UserAccount {
            _savedFeedLoader = .init(wrappedValue: .init(
                api: AppState.main.firstApi,
                userId: firstUser.id,
                sortType: .new,
                savedOnly: true,
                smallAvatarSize: Constants.main.smallAvatarSize,
                largeAvatarSize: Constants.main.largeAvatarSize
            ))
            _feedOptions = .init(wrappedValue: FeedSelection.allCases)
        } else {
            _feedOptions = .init(wrappedValue: FeedSelection.guestCases)
        }
    }
    
    var body: some View {
        content
            .background(postSize.tiled ? palette.groupedBackground : palette.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarEllipsisMenu {
                    MenuButton(action: BasicAction(
                        id: "read",
                        isOn: showRead,
                        label: showRead ? "Hide Read" : "Show Read",
                        color: palette.primary,
                        icon: Icons.read
                    ) {
                        showRead = !showRead
                    })
                }
            }
            .loadFeed(postFeedLoader)
            .loadFeed(savedFeedLoader)
            .onChange(of: showRead) {
                scrollToTopTrigger.toggle()
                Task {
                    do {
                        if showRead {
                            try await postFeedLoader.removeFilter(.read)
                        } else {
                            try await postFeedLoader.addFilter(.read)
                        }
                    } catch {
                        handleError(error)
                    }
                }
            }
            .onChange(of: appState.firstApi, initial: false) {
                postFeedLoader.api = appState.firstApi

                if appState.firstApi.willSendToken, let firstUser = appState.firstAccount as? UserAccount {
                    feedOptions = FeedSelection.allCases
                    if let savedFeedLoader {
                        savedFeedLoader.switchUser(api: appState.firstApi, userId: firstUser.id)
                    } else {
                        savedFeedLoader = .init(
                            api: appState.firstApi,
                            userId: firstUser.id,
                            sortType: .new,
                            savedOnly: true,
                            smallAvatarSize: Constants.main.smallAvatarSize,
                            largeAvatarSize: Constants.main.largeAvatarSize
                        )
                    }
                } else {
                    feedOptions = FeedSelection.guestCases
                    savedFeedLoader = nil

                    // ensure we only show non-authenticated feeds to non-authenticated users
                    if !FeedSelection.guestCases.contains(feedSelection) {
                        feedSelection = .all
                    }
                }
            }
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
                    PersonContentGridView(feedLoader: savedFeedLoader)
                } else {
                    PostGridView(postFeedLoader: postFeedLoader)
                }
            } header: {
                Menu {
                    ForEach(feedOptions, id: \.self) { feed in
                        Button(
                            String(localized: feed.description.label),
                            systemImage: feedSelection == feed ? feed.description.iconNameFill : feed.description.iconName
                        ) {
                            feedSelection = feed
                        }
                    }
                } label: {
                    FeedHeaderView(feedDescription: feedSelection.description, dropdownStyle: .enabled(showBadge: false))
                        .padding(.bottom, Constants.main.standardSpacing)
                }
                .buttonStyle(.plain)
            } footer: {
                Group {
                    switch postFeedLoader.loadingState {
                    case .loading:
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
}
