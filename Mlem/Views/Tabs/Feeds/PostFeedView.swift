//
//  PostFeedView.swift
//  Mlem
//
//  Created by Sjmarf on 31/12/2023.
//

import Dependencies
import SwiftUI

struct PostFeedView: View {
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.siteInformation) var siteInformation

    @AppStorage("shouldShowPostCreator") var shouldShowPostCreator: Bool = true
    @AppStorage("showReadPosts") var showReadPosts: Bool = true
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("postSize") var postSize: PostSize = .large
    
    @EnvironmentObject var filtersTracker: FiltersTracker
    @EnvironmentObject var appState: AppState
    @ObservedObject var postTracker: PostTracker
    
    var community: CommunityModel?
    
    @Binding var postSortType: PostSortType
    
    @State var shouldLoad: Bool = false
    @State var errorDetails: ErrorDetails?
    
    init(
        community: CommunityModel? = nil,
        postTracker: PostTracker,
        postSortType: Binding<PostSortType>
    ) {
        self.community = community
        self._postTracker = .init(wrappedValue: postTracker)
        self._postSortType = postSortType
    }
    
    var body: some View {
        LazyVStack(spacing: 0) {
            if postTracker.items.isEmpty {
                noPostsView()
                    .padding(.top)
                    .frame(maxWidth: .infinity)
                    .frame(height: 400)
            } else {
                Group {
                    ForEach(postTracker.items, id: \.uid) { post in
                        feedPost(for: post)
                    }
                    // TODO: update to use proper LoadingState
                    EndOfFeedView(loadingState: postTracker.showLoadingIcon && postTracker.page > 1 ? .loading : .done, viewType: .hobbit)
                }
                .transition(.opacity)
            }
        }
        .environmentObject(postTracker)
        .animation(.easeOut(duration: 0.2), value: postTracker.items.isEmpty)
        .toolbar {
            ToolbarItem(placement: .primaryAction) { sortMenu }
            ToolbarItemGroup(placement: .secondaryAction) {
                ForEach(genEllipsisMenuFunctions()) { menuFunction in
                    MenuButton(menuFunction: menuFunction, confirmDestructive: nil)
                }
                Menu {
                    ForEach(genPostSizeSwitchingFunctions()) { menuFunction in
                        MenuButton(menuFunction: menuFunction, confirmDestructive: nil)
                    }
                } label: {
                    Label("Post Size", systemImage: Icons.postSizeSetting)
                }
            }
        }
        .onAppear {
            if postTracker.showLoadingIcon {
                Task(priority: .userInitiated) {
                    postTracker.handleError = handle
                    postTracker.filter = filter
                    await postTracker.initFeed()
                }
            }
        }
        .onChange(of: postTracker.items) { newValue in
            if !newValue.isEmpty {
                errorDetails = nil
            }
        }
        .onChange(of: postTracker.type) { _ in
            Task(priority: .userInitiated) {
                await postTracker.refresh(clearBeforeFetch: true)
            }
        }
        .onChange(of: postSortType) { newValue in
            Task(priority: .userInitiated) {
                switch postTracker.type {
                case let .feed(feedType, _):
                    postTracker.type = .feed(feedType, sortedBy: newValue)
                case let .community(community, _):
                    postTracker.type = .community(community, sortedBy: newValue)
                case nil:
                    break
                }
            }
        }
        .onChange(of: appState.currentActiveAccount) { _ in
            Task(priority: .userInitiated) {
                setDefaultSortMode()
                await postTracker.refresh(clearBeforeFetch: true)
            }
        }
        .onChange(of: showReadPosts) { _ in
            Task(priority: .userInitiated) {
                postTracker.filter = filter
                await postTracker.refresh(clearBeforeFetch: true)
            }
        }
        .onChange(of: shouldLoad) { value in
            if value {
                print("should load more posts...")
                Task(priority: .medium) { await postTracker.loadNextPage() }
                shouldLoad = false
            }
        }
    }
    
    @ViewBuilder
    private func feedPost(for post: PostModel) -> some View {
        VStack(spacing: 0) {
            NavigationLink(.postLinkWithContext(.init(post: post, community: community, postTracker: postTracker))) {
                FeedPost(
                    post: post,
                    community: community,
                    showPostCreator: shouldShowPostCreator,
                    showCommunity: community == nil
                )
            }
            Divider()
        }
        .buttonStyle(EmptyButtonStyle()) // Make it so that the link doesn't mess with the styling
        .onAppear {
            // on appear, flag whether new content should be loaded. Actual loading is attached to the feed view itself so that it doesn't get cancelled by view derenders
            if postTracker.shouldLoadContentAfter(after: post) {
                shouldLoad = true
            }
        }
    }
    
    @ViewBuilder
    private func noPostsView() -> some View {
        VStack {
            if postTracker.showLoadingIcon { // don't show posts until site information loads to avoid jarring redraw
                LoadingView(whatIsLoading: .posts)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
            } else if let errorDetails {
                ErrorView(errorDetails)
                    .frame(maxWidth: .infinity)
            } else {
                NoPostsView(isLoading: $postTracker.showLoadingIcon, postSortType: $postSortType, showReadPosts: $showReadPosts)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .padding(.top, 25)
            }
        }
        .animation(.easeOut(duration: 0.1), value: postTracker.showLoadingIcon)
    }
    
    @ViewBuilder
    private var sortMenu: some View {
        Menu {
            ForEach(genOuterSortMenuFunctions()) { menuFunction in
                MenuButton(menuFunction: menuFunction, confirmDestructive: nil) // no destructive sorts
            }
            
            Menu {
                ForEach(genTopSortMenuFunctions()) { menuFunction in
                    MenuButton(menuFunction: menuFunction, confirmDestructive: nil) // no destructive sorts
                }
            } label: {
                Label("Top...", systemImage: Icons.topSort)
            }
        } label: {
            Label(
                "Selected sorting by \(postSortType.description)",
                systemImage: postSortType.iconName
            )
        }
    }
}
