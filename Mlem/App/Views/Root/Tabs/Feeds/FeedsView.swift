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
    @Environment(AppState.self) var appState
    
    var body: some View {
        content
            .navigationTitle("Feeds")
    }
    
    var content: some View {
        MinimalPostFeedView()
    }
}

struct MinimalPostFeedView: View {
    @AppStorage("post.size") var postSize: PostSize = .large
    @AppStorage("feed.showRead") var showRead: Bool = true
    @AppStorage("beta.tilePosts") var tilePosts: Bool = false
    
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    @State var postFeedLoader: StandardPostFeedLoader
    
    @State var columns: [GridItem] = [GridItem(.flexible())]
    
    init() {
        // need to grab some stuff from app storage to initialize with
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        @AppStorage("feed.showRead") var showReadPosts = true
        @AppStorage("defaultPostSorting") var defaultPostSorting: ApiSortType = .hot
        
        @Dependency(\.persistenceRepository) var persistenceRepository
        
        _postFeedLoader = .init(initialValue: .init(
            pageSize: internetSpeed.pageSize,
            sortType: .topYear, // defaultPostSorting,
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
            .navigationTitle("Feeds")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: tilePosts, initial: true) { _, newValue in
                if newValue {
                    columns = [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)]
                } else {
                    columns = [GridItem(.flexible())]
                }
            }
            .task(id: showRead) {
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
            .task(id: appState.firstApi) {
                do {
                    try await postFeedLoader.refresh(clearBeforeRefresh: true)
                } catch {
                    handleError(error)
                }
            }
            .task(id: appState.firstApi) {
                do {
                    try await postFeedLoader.changeFeedType(to: .aggregateFeed(appState.firstApi, type: .subscribed))
                } catch {
                    handleError(error)
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
        FancyScrollView {
            LazyVGrid(columns: columns, spacing: tilePosts ? AppConstants.standardSpacing : 0) {
                if !tilePosts { Divider() }
                
                Button("\(showRead ? "Hide" : "Show") read") {
                    showRead = !showRead
                }
                
                ForEach(postFeedLoader.items, id: \.uid) { post in
                    if !post.read || showRead {
                        VStack(spacing: 0) { // this improves performance O_o
                            NavigationLink(value: NavigationPage.expandedPost(post)) {
                                FeedPostView(post: .init(post: post))
                                    .contentShape(.rect)
                            }
                            .buttonStyle(EmptyButtonStyle())
                            if !tilePosts { Divider() }
                        }
                    }
                }
                
                switch postFeedLoader.loadingState {
                case .loading:
                    Text("Loading...")
                case .done:
                    Text("Done")
                case .idle:
                    Text("Idle")
                }
            }
            .padding(.horizontal, tilePosts ? AppConstants.halfSpacing : 0)
        }
    }
    
    // This is a proof-of-concept; in the real frontend this code will go in InteractionBarView
    @ViewBuilder
    func actionButton(_ action: BasicAction) -> some View {
        Button(action: action.callback ?? {}) {
            Image(systemName: action.barIcon)
                .foregroundColor(action.isOn ? palette.selectedInteractionBarItem : palette.primary)
                .padding(2)
                .background(
                    RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                        .fill(action.isOn ? action.color : .clear)
                )
        }
        .buttonStyle(EmptyButtonStyle())
        .disabled(action.callback == nil)
        .opacity(action.callback == nil ? 0.5 : 1)
    }
}
