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
    @AppStorage("post.size") var postSize: PostSize = .large
    @AppStorage("feed.showRead") var showRead: Bool = true
    @AppStorage("beta.tilePosts") var tilePosts: Bool = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    @State var postFeedLoader: StandardPostFeedLoader
    @State var feedSelection: FeedSelection {
        didSet {
            Task {
                do {
                    try await postFeedLoader.changeFeedType(to: .aggregateFeed(appState.firstApi, type: feedSelection.associatedApiType))
                } catch {
                    handleError(error)
                }
            }
        }
    }

    @State var scrollToTopTrigger: Bool = false
    
    enum FeedSelection: CaseIterable {
        case all, local, subscribed
        // TODO: moderated, saved
        
        var description: FeedDescription {
            switch self {
            case .all: .all
            case .local: .local
            case .subscribed: .subscribed
            }
        }
        
        var associatedApiType: ApiListingType {
            switch self {
            case .all: .all
            case .local: .local
            case .subscribed: .subscribed
            }
        }
    }
    
    init() {
        // need to grab some stuff from app storage to initialize with
        @AppStorage("behavior.internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("behavior.upvoteOnSave") var upvoteOnSave = false
        @AppStorage("feed.showRead") var showReadPosts = true
        @AppStorage("post.defaultSort") var defaultSort: ApiSortType = .hot
        
        @Dependency(\.persistenceRepository) var persistenceRepository
        
        let initialFeedSelection: FeedSelection = .subscribed
        _feedSelection = .init(initialValue: initialFeedSelection)
        _postFeedLoader = .init(initialValue: .init(
            pageSize: internetSpeed.pageSize,
            sortType: .new,
            showReadPosts: showReadPosts,
            // Don't load from PersistenceRepository directly here, as we'll be reading from file every time the view is initialized, which can happen frequently
            filteredKeywords: [],
            feedType: .aggregateFeed(AppState.main.firstApi, type: initialFeedSelection.associatedApiType),
            smallAvatarSize: AppConstants.smallAvatarSize,
            largeAvatarSize: AppConstants.largeAvatarSize,
            urlCache: AppConstants.urlCache
        ))
    }
    
    var body: some View {
        content
            .background(tilePosts ? palette.groupedBackground : palette.background)
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
            .refreshable {
                do {
                    let newFeedType: StandardPostFeedLoader.FeedType = .aggregateFeed(
                        appState.firstApi,
                        type: feedSelection.associatedApiType
                    )
                    
                    // If the account has changed, we need to update the `feedType`.
                    if postFeedLoader.feedType != newFeedType {
                        try await postFeedLoader.changeFeedType(to: newFeedType)
                    } else {
                        try await postFeedLoader.refresh(clearBeforeRefresh: false)
                    }
                } catch {
                    handleError(error)
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        FancyScrollView(scrollToTopTrigger: $scrollToTopTrigger) {
            Section {
                if !tilePosts { Divider() }
                PostGridView(postFeedLoader: postFeedLoader)
            } header: {
                Menu {
                    ForEach(FeedSelection.allCases, id: \.self) { feed in
                        Button(
                            feed.description.label,
                            systemImage: feedSelection == feed ? feed.description.iconNameFill : feed.description.iconName
                        ) {
                            feedSelection = feed
                        }
                    }
                } label: {
                    FeedHeaderView(feedDescription: feedSelection.description, dropdownStyle: .enabled(showBadge: false))
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
