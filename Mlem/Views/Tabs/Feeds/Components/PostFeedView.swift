//
//  PostFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-13.
//

import Dependencies
import Foundation
import SwiftUI

struct PostFeedView: View {
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.siteInformation) var siteInformation
    
    @AppStorage("shouldShowPostCreator") var shouldShowPostCreator: Bool = true
    @AppStorage("showReadPosts") var showReadPosts: Bool = true
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("postSize") var postSize: PostSize = .large
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
    @AppStorage("fallbackDefaultPostSorting") var fallbackDefaultPostSorting: PostSortType = .hot
    
    @EnvironmentObject var postTracker: StandardPostTracker
    @EnvironmentObject var appState: AppState
    
    // used to actually drive post loading; when nil, indicates that the site version is unresolved and it is not safe to load posts
    @State var versionSafePostSort: PostSortType?
    @Binding var postSortType: PostSortType {
        didSet {
            versionSafePostSort = postSortType
        }
    }
    
    // If versionSafePostSort is defined at init, the post tracker won't detect that and start loading until a fraction of a second after the view draws; if the tracker is also empty, this leads to noPostsView flashing for a fraction of a second. This masks that behavior.
    @State var suppressNoPostsView: Bool = true

    let showCommunity: Bool
    let communityContext: CommunityModel?

    @State var errorDetails: ErrorDetails?
    
    init(postSortType: Binding<PostSortType>, showCommunity: Bool, communityContext: CommunityModel? = nil) {
        @Dependency(\.siteInformation) var siteInformation
        
        if let siteVersion = siteInformation.version, postSortType.wrappedValue.minimumVersion <= siteVersion {
            self._versionSafePostSort = .init(wrappedValue: postSortType.wrappedValue)
        }
        
        self._postSortType = postSortType
        self.showCommunity = showCommunity
        self.communityContext = communityContext
    }
    
    var body: some View {
        content
            .animation(.easeOut(duration: 0.2), value: postTracker.items.isEmpty)
            .onChange(of: showReadPosts) { newValue in
                if newValue {
                    Task { await postTracker.removeFilter(.read) }
                } else {
                    Task { await postTracker.addFilter(.read) }
                }
            }
            .task(id: siteInformation.version) {
                await setDefaultSortMode()
            }
            .task(id: versionSafePostSort) {
                defer { suppressNoPostsView = false }
                
                if let versionSafePostSort {
                    await postTracker.changeSortType(
                        to: versionSafePostSort,
                        forceRefresh: postTracker.items.isEmpty
                    )
                }
            }
            .toolbar {
                if versionSafePostSort != nil {
                    if postTracker.feedType != .saved {
                        ToolbarItem(placement: .primaryAction) { sortMenu }
                    }
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
            }
    }
    
    var content: some View {
        LazyVStack(spacing: 0) {
            if postTracker.items.isEmpty || versionSafePostSort == nil {
                noPostsView()
            } else {
                ForEach(postTracker.items, id: \.uid) { feedPost(for: $0) }
                EndOfFeedView(loadingState: postTracker.loadingState, viewType: .hobbit)
            }
        }
    }
    
    @ViewBuilder
    private func feedPost(for post: PostModel) -> some View {
        VStack(spacing: 0) {
            NavigationLink(.postLinkWithContext(.init(post: post, community: nil, postTracker: postTracker))) {
                FeedPost(
                    post: post,
                    community: communityContext,
                    showPostCreator: shouldShowPostCreator,
                    showCommunity: showCommunity
                )
            }
            
            Divider()
        }
        .onAppear { postTracker.loadIfThreshold(post) }
        .buttonStyle(EmptyButtonStyle()) // Make it so that the link doesn't mess with the styling
    }
    
    @ViewBuilder
    private func noPostsView() -> some View {
        VStack {
            // don't show posts until site information loads to avoid jarring redraw
            if postTracker.loadingState == .loading || versionSafePostSort == nil || suppressNoPostsView {
                LoadingView(whatIsLoading: .posts)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
            } else if let errorDetails {
                ErrorView(errorDetails)
                    .frame(maxWidth: .infinity)
            } else {
                NoPostsView(loadingState: postTracker.loadingState, postSortType: postSortType, showReadPosts: $showReadPosts) {
                    suppressNoPostsView = true
                    postSortType = .hot
                }
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.1), value: postTracker.loadingState)
        .animation(.easeOut(duration: 0.1), value: suppressNoPostsView)
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
