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
    
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("shouldShowPostCreator") var shouldShowPostCreator: Bool = true
    @AppStorage("showReadPosts") var showReadPosts: Bool = true
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("postSize") var postSize: PostSize = .large
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
    @AppStorage("fallbackDefaultPostSorting") var fallbackDefaultPostSorting: PostSortType = .hot
    
    @EnvironmentObject var postTracker: StandardPostTracker
    @EnvironmentObject var appState: AppState
    
    @Binding var postSortType: PostSortType
    let showCommunity: Bool
    
    @State var siteVersionResolved: Bool = false
    @State var errorDetails: ErrorDetails?
    
    var body: some View {
        content
            .onChange(of: showReadPosts) { newValue in
                if newValue {
                    Task { await postTracker.removeFilter(.read) }
                } else {
                    Task { await postTracker.addFilter(.read) }
                }
            }
            .task(id: siteInformation.version) {
                // when site version changes, check if it's resolved; if so, update sort type and siteVersionResolved
                if let siteVersion = siteInformation.version, !siteVersionResolved {
                    let newPostSort = siteVersion < defaultPostSorting.minimumVersion ? fallbackDefaultPostSorting : defaultPostSorting
                    
                    // manually change the tracker sort type here so that view is not redrawn by `onChange(of: postSortType)`
                    await postTracker.changeSortType(to: newPostSort, forceRefresh: true)
                    postSortType = newPostSort
                    siteVersionResolved = true
                }
            }
            .onChange(of: postSortType) { newValue in
                Task { await postTracker.changeSortType(to: newValue) }
            }
            .toolbar {
                if siteVersionResolved {
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
            .hoistNavigation(dismiss: dismiss)
    }
    
    var content: some View {
        LazyVStack(spacing: 0) {
            if postTracker.items.isEmpty || !siteVersionResolved {
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
            // TODO: reenable nav
            NavigationLink(.postLinkWithContext(.init(post: post, community: nil, postTracker: postTracker))) {
                FeedPost(
                    post: post,
                    community: post.community,
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
            if postTracker.loadingState == .loading || !siteVersionResolved {
                LoadingView(whatIsLoading: .posts)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
            } else if let errorDetails {
                ErrorView(errorDetails)
                    .frame(maxWidth: .infinity)
            } else {
                NoPostsView(loadingState: postTracker.loadingState, postSortType: $postSortType, showReadPosts: $showReadPosts)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .padding(.top, 25)
            }
        }
        .animation(.easeOut(duration: 0.1), value: postTracker.loadingState)
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
