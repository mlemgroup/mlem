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
    
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    @State var postFeedLoader: StandardPostFeedLoader
    @State var columns: [GridItem] = [GridItem(.flexible())]
    @State var scrollToTopTrigger: Bool = false
    
    init() {
        // need to grab some stuff from app storage to initialize with
        @AppStorage("behavior.internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("behavior.upvoteOnSave") var upvoteOnSave = false
        @AppStorage("feed.showRead") var showReadPosts = true
        @AppStorage("post.defaultSort") var defaultSort: ApiSortType = .topYear // .hot
        
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
            .onChange(of: tilePosts, initial: true) { _, newValue in
                if newValue {
                    // leading/trailing alignment makes them want to stick to each other, allowing the AppConstants.halfSpacing padding applied below
                    // to push them apart by a sum of AppConstants.standardSpacing
                    columns = [
                        GridItem(.flexible(), spacing: 0, alignment: .trailing),
                        GridItem(.flexible(), spacing: 0, alignment: .leading)
                    ]
                } else {
                    columns = [GridItem(.flexible())]
                }
            }
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
            .task(id: appState.firstApi) {
                do {
                    try await postFeedLoader.changeFeedType(to: .aggregateFeed(appState.firstApi, type: .subscribed))
                } catch {
                    handleError(error)
                }
            }
            .task {
                // NOTE: this is here due to an error in StandardPostFeedLoader where changing feed type doesn't properly reload, resulting in
                // the first render not triggering a load. I'm currently working on a fix, but it's OOS for filtering
                // -Eric
                if postFeedLoader.items.isEmpty, postFeedLoader.loadingState == .idle {
                    do {
                        try await postFeedLoader.refresh(clearBeforeRefresh: true)
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
            LazyVGrid(columns: columns, spacing: tilePosts ? AppConstants.standardSpacing : 0) {
                // Section lets the header and loading footer play nice regardless of column count
                Section {
                    if !tilePosts { Divider() }
                    
                    ForEach(postFeedLoader.items, id: \.hashValue) { post in
                        if !post.read || showRead {
                            VStack(spacing: 0) { // this improves performance O_o
                                NavigationLink(value: NavigationPage.expandedPost(post)) {
                                    FeedPostView(post: post)
                                }
                                .buttonStyle(EmptyButtonStyle())
                                if !tilePosts { Divider() }
                            }
                            .padding(.horizontal, tilePosts ? AppConstants.halfSpacing : 0)
                            .onAppear {
                                do {
                                    try postFeedLoader.loadIfThreshold(post)
                                } catch {
                                    handleError(error)
                                }
                            }
                        }
                    }
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
    }
    
    @ViewBuilder
    var header: some View {
        switch postFeedLoader.feedType {
        case let .aggregateFeed(_, type):
            switch type {
            case .all: FeedHeaderView(feedDescription: .all)
            case .local: FeedHeaderView(feedDescription: .local)
            case .subscribed: FeedHeaderView(feedDescription: .subscribed)
            case .moderatorView: FeedHeaderView(feedDescription: .moderated)
            }
        case .community: FeedHeaderView(feedDescription: .subscribed) // TODO:
        }
    }
}
