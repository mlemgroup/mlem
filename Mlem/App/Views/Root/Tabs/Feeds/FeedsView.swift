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
    
    @State var postFeedLoader: AggregatePostFeedLoader
    @State var savedFeedLoader: UserContentFeedLoader?
    @State var feedOptions: [FeedSelection] = FeedSelection.guestCases
    @State var feedSelection: FeedSelection {
        didSet {
            // ignore saved because it uses a different loader
            guard feedSelection != .saved else { return }
            Task {
                do {
                    try await postFeedLoader.changeFeedType(to: feedSelection.associatedApiType)
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
            smallAvatarSize: AppConstants.smallAvatarSize,
            largeAvatarSize: AppConstants.largeAvatarSize,
            urlCache: AppConstants.urlCache,
            api: AppState.main.firstApi,
            feedType: initialFeedSelection.associatedApiType
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
            .onChange(of: appState.firstApi, initial: false) {
                postFeedLoader.api = appState.firstApi
                if feedSelection == .saved, !appState.firstApi.willSendToken {
                    feedSelection = .all
                }
            }
            .onChange(of: appState.firstApi, initial: true) {
                if let firstUser = appState.firstAccount as? UserAccount {
                    savedFeedLoader = .init(
                        api: appState.firstApi,
                        userId: firstUser.id,
                        sortType: .new,
                        savedOnly: true
                    )
                    Task(priority: .userInitiated) {
                        do {
                            try await savedFeedLoader?.loadMoreItems()
                        } catch {
                            handleError(error)
                        }
                    }
                    feedOptions = FeedSelection.allCases
                } else {
                    feedOptions = FeedSelection.guestCases
                }
            }
            .refreshable {
                do {
                    switch feedSelection {
                    case .all, .local, .subscribed:
                        try await postFeedLoader.refresh(clearBeforeRefresh: false)
                    case .saved:
                        try await savedFeedLoader?.refresh(clearBeforeRefresh: false)
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
                
                if let savedFeedLoader {
                    if feedSelection == .saved {
                        UserContentGridView(feedLoader: savedFeedLoader)
                    } else {
                        PostGridView(postFeedLoader: postFeedLoader)
                    }
                } else {
                    PostGridView(postFeedLoader: postFeedLoader)
                }
            } header: {
                Menu {
                    ForEach(feedOptions, id: \.self) { feed in
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
