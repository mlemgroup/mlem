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
    @State var scrollToTopTrigger: Bool = false
    
    init() {
        // need to grab some stuff from app storage to initialize with
        @AppStorage("behavior.internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("behavior.upvoteOnSave") var upvoteOnSave = false
        @AppStorage("feed.showRead") var showReadPosts = true
        @AppStorage("post.defaultSort") var defaultSort: ApiSortType = .hot
        
        @Dependency(\.persistenceRepository) var persistenceRepository
        
        _postFeedLoader = .init(initialValue: .init(
            pageSize: internetSpeed.pageSize,
            sortType: defaultSort,
            showReadPosts: showReadPosts,
            // Don't load from PersistenceRepository directly here, as we'll be reading from file every time the view is initialized, which can happen frequently
            filteredKeywords: [],
            feedType: .aggregateFeed(AppState.main.firstApi, type: .subscribed),
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
            .preheatFeedLoader(postFeedLoader)
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
            .onChange(of: appState.firstApi, initial: false) { newValue, _ in
                Task {
                    do {
                        try await postFeedLoader.changeFeedType(to: .aggregateFeed(newValue, type: .subscribed))
                    } catch {
                        handleError(error)
                    }
                }
            }
            .refreshable {
                do {
                    try await postFeedLoader.refresh(clearBeforeRefresh: false)
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
                header
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
    
    @ViewBuilder
    var header: some View {
        switch postFeedLoader.feedType {
        case let .aggregateFeed(_, type):
            switch type {
            case .all: FeedHeaderView(feedDescription: .all, actions: headerMenuActions)
            case .local: FeedHeaderView(feedDescription: .local, actions: headerMenuActions)
            case .subscribed: FeedHeaderView(feedDescription: .subscribed, actions: headerMenuActions)
            case .moderatorView: FeedHeaderView(feedDescription: .moderated)
            }
        case .community: FeedHeaderView(feedDescription: .subscribed) // TODO:
        }
    }
}
