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
    
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    @State var postTracker: StandardPostFeedLoader
    @State private var scrollToTopAppeared = false
    @State var columns: [GridItem] = [GridItem(.flexible())]
    
    @Namespace var scrollToTop
    
    init() {
        // need to grab some stuff from app storage to initialize with
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        @AppStorage("showReadPosts") var showReadPosts = true
        @AppStorage("defaultPostSorting") var defaultPostSorting: ApiSortType = .hot
        
        @Dependency(\.persistenceRepository) var persistenceRepository
        
        _postTracker = .init(initialValue: .init(
            pageSize: internetSpeed.pageSize,
            sortType: defaultPostSorting,
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
        ScrollViewReader { scrollProxy in
            content
                .background(postSize == .tile ? palette.groupedBackground : palette.background)
                .navigationTitle("Feeds")
                .onChange(of: postSize, initial: true) { _, newValue in
                    columns = newValue.columns
                }
                .task {
                    if postTracker.items.isEmpty, postTracker.loadingState == .idle {
                        print("Loading initial PostTracker page...")
                        do {
                            try await postTracker.loadMoreItems()
                        } catch {
                            handleError(error)
                        }
                    }
                }
                .task(id: appState.firstApi) {
                    do {
                        try await postTracker.changeFeedType(to: .aggregateFeed(appState.firstApi, type: .subscribed))
                    } catch {
                        handleError(error)
                    }
                }
                .refreshable {
                    do {
                        try await postTracker.refresh(clearBeforeRefresh: false)
                    } catch {
                        handleError(error)
                    }
                }
                .onReselectTab {
                    if !scrollToTopAppeared {
                        withAnimation {
                            scrollProxy.scrollTo(scrollToTop)
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    var content: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: postSize == .tile ? AppConstants.standardSpacing : 0) {
                Section {
                    if postSize != .tile { Divider() }
                    
                    ForEach(postTracker.items, id: \.uid) { post in
                        VStack(spacing: 0) { // this improves performance O_o
                            NavigationLink(value: NavigationPage.expandedPost(post)) {
                                FeedPostView(post: .init(post: post))
                                    .contentShape(.rect)
                            }
                            .buttonStyle(EmptyButtonStyle())
                            if postSize != .tile { Divider() }
                        }
                    }
                    
                    switch postTracker.loadingState {
                    case .loading:
                        Text("Loading...")
                    case .done:
                        Text("Done")
                    case .idle:
                        Text("Idle")
                    }
                } header: {
                    // putting this in a section header makes it play nice with any number of columns
                    ScrollToView(appeared: $scrollToTopAppeared)
                        .id(scrollToTop)
                }
            }
            .padding(.horizontal, postSize == .tile ? AppConstants.halfSpacing : 0)
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
