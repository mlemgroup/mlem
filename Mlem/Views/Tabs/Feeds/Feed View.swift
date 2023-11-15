//
//  Feed View (new).swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-21.
//

import Dependencies
import Foundation
import SwiftUI

struct FeedView: View {
    // MARK: Environment and settings
    
    @Dependency(\.communityRepository) var communityRepository
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.favoriteCommunitiesTracker) var favoriteCommunitiesTracker
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.notifier) var notifier
    @Dependency(\.siteInformation) var siteInformation
    
    @AppStorage("shouldShowCommunityHeaders") var shouldShowCommunityHeaders: Bool = false
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("shouldShowPostCreator") var shouldShowPostCreator: Bool = true
    @AppStorage("postSize") var postSize: PostSize = .large
    @AppStorage("showReadPosts") var showReadPosts: Bool = true
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var scrollState: ScrollState
    @EnvironmentObject var filtersTracker: FiltersTracker
    @EnvironmentObject var editorTracker: EditorTracker
    
    // MARK: Parameters and init
    
    @State var community: CommunityModel?
    @State var feedType: FeedType
    
    @State var errorDetails: ErrorDetails?
    
    init(
        community: CommunityModel?,
        feedType: FeedType
    ) {
        // need to grab some stuff from app storage to initialize post tracker with
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        
        self._feedType = State(initialValue: feedType)
        self._postTracker = StateObject(wrappedValue: .init(
            shouldPerformMergeSorting: false,
            internetSpeed: internetSpeed,
            upvoteOnSave: upvoteOnSave
        ))
        
        self._community = State(initialValue: community)
        
        @AppStorage("fallbackDefaultPostSorting") var fallbackDefaultPostSorting: PostSortType = .hot
        _postSortType = .init(initialValue: fallbackDefaultPostSorting)
    }
    
    // MARK: State
    
    @StateObject var postTracker: PostTracker
    
    @State var postSortType: PostSortType
    @State var isLoading: Bool = true
    @State var siteInformationLoading: Bool = true
    @State var shouldLoad: Bool = false
    
    @AppStorage("hasTranslucentInsets") var hasTranslucentInsets: Bool = true
    
    // MARK: Destructive confirmation
    
    @State private var isPresentingConfirmDestructive: Bool = false
    @State private var confirmationMenuFunction: StandardMenuFunction?
    
    func confirmDestructive(destructiveFunction: StandardMenuFunction) {
        confirmationMenuFunction = destructiveFunction
        isPresentingConfirmDestructive = true
    }
    
    // MARK: - Main Views
    
    var body: some View {
        contentView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(hasTranslucentInsets ? Color.secondarySystemBackground : Color.systemBackground)
            .toolbar {
                ToolbarItem(placement: .principal) { toolbarHeader }
                ToolbarItem(placement: .navigationBarTrailing) { sortMenu }
                ToolbarItemGroup(placement: .navigationBarTrailing) { ellipsisMenu }
            }
            .navigationBarTitleDisplayMode(.inline)
            /// [2023.08] Set to `.visible` to workaround bug where navigation bar background may disappear on certain devices when device rotates.
            .navigationBarColor(visibility: .visible)
            .environmentObject(postTracker)
            .task(id: siteInformation.version) {
                // update post sort once we have siteInformation. Assumes site version won't change once we receive it.
                if let siteVersion = siteInformation.version, siteInformationLoading {
                    siteInformationLoading = false
                    
                    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
                    @AppStorage("fallbackDefaultPostSorting") var fallbackDefaultPostSorting: PostSortType = .hot
                    if siteVersion >= defaultPostSorting.minimumVersion {
                        postSortType = defaultPostSorting
                    } else {
                        postSortType = fallbackDefaultPostSorting
                    }
                    Task(priority: .userInitiated) {
                        await initFeed()
                    }
                }
            }
            .task(priority: .background) { await fetchCommunityDetails() }
            // using hardRefreshFeed() for these three so that the user gets immediate feedback, also kills the ScrollViewReader
            .onChange(of: feedType) { _ in
                Task(priority: .userInitiated) {
                    await hardRefreshFeed()
                }
            }
            .onChange(of: postSortType) { _ in
                Task(priority: .userInitiated) {
                    await hardRefreshFeed()
                }
            }
            .onChange(of: appState.currentActiveAccount) { _ in
                Task(priority: .userInitiated) {
                    await hardRefreshFeed()
                }
            }
            .onChange(of: showReadPosts) { _ in
                Task(priority: .userInitiated) {
                    await hardRefreshFeed()
                }
            }
            .onChange(of: shouldLoad) { value in
                if value {
                    print("should load more posts...")
                    Task(priority: .medium) { await loadFeed() }
                    shouldLoad = false
                }
            }
            .refreshable {
                await refreshFeed()
            }
    }
    
    @ViewBuilder
    private var contentView: some View {
        ScrollViewReader { reader in
            ScrollView {
                if !postTracker.items.isEmpty {
                    LazyVStack(spacing: 0) {
                        EmptyView()
                            .id("topOfFeed")
                        
                        // note: using .uid here because .id causes swipe actions to break--state changes still seem to properly trigger rerenders this way 🤔
                        ForEach(postTracker.items, id: \.uid) { post in
                            feedPost(for: post)
                        }
                        
                        // TODO: update to use proper LoadingState
                        EndOfFeedView(loadingState: isLoading && postTracker.page > 1 ? .loading : .done, viewType: .hobbit)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .overlay {
                if postTracker.items.isEmpty {
                    noPostsView()
                }
            }
            .fancyTabScrollCompatible()
            .onChange(of: scrollState.shouldScrollToTop) { value in
                if value {
                    withAnimation(.smooth(duration: 5, extraBounce: 3.0)) {
                        reader.scrollTo("topOfFeed", anchor: .bottomLeading)
                    }
                    scrollState.shouldScrollToTop = false
                    print("scrolled to top")
                }
            }
        }
    }
    
    @ViewBuilder
    private func noPostsView() -> some View {
        VStack {
            if let errorDetails {
                ErrorView(errorDetails)
                    .frame(maxWidth: .infinity)
            } else if isLoading || siteInformationLoading { // don't show posts until site information loads to avoid jarring redraw
                LoadingView(whatIsLoading: .posts)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
            } else {
                NoPostsView(isLoading: $isLoading, postSortType: $postSortType, showReadPosts: $showReadPosts)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.1), value: isLoading)
    }
    
    // MARK: Helper Views
    
    @ViewBuilder
    private func feedPost(for post: PostModel) -> some View {
        VStack(spacing: 0) {
            // TODO: reenable nav
            NavigationLink(.postLinkWithContext(.init(post: post, postTracker: postTracker))) {
                FeedPost(
                    post: post,
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
    private var ellipsisMenu: some View {
        Menu {
            if let community {
                // until we find a nice way to put nav stuff in MenuFunction, this'll have to do :(
                NavigationLink(.communitySidebarLinkWithContext(
                    .init(
                        community: community
                    )
                )) {
                    Label("Sidebar", systemImage: "sidebar.right")
                }
                
                ForEach(genCommunitySpecificMenuFunctions()) { menuFunction in
                    MenuButton(menuFunction: menuFunction, confirmDestructive: confirmDestructive)
                }
            }
            
            Divider()
            
            ForEach(genEllipsisMenuFunctions()) { menuFunction in
                MenuButton(menuFunction: menuFunction, confirmDestructive: confirmDestructive)
            }
            
            Menu {
                ForEach(genPostSizeSwitchingFunctions()) { menuFunction in
                    MenuButton(menuFunction: menuFunction, confirmDestructive: confirmDestructive)
                }
            } label: {
                Label("Post Size", systemImage: Icons.postSizeSetting)
            }
        } label: {
            Label("More", systemImage: "ellipsis")
                .frame(height: AppConstants.barIconHitbox)
                .contentShape(Rectangle())
        }
        .destructiveConfirmation(
            isPresentingConfirmDestructive: $isPresentingConfirmDestructive,
            confirmationMenuFunction: confirmationMenuFunction
        )
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
    
    @ViewBuilder
    private var toolbarHeader: some View {
        if let community {
            NavigationLink(.communitySidebarLinkWithContext(.init(
                community: community
            ))) {
                Text(community.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibilityHint("Activate to view sidebar.")
            }
        } else {
            Menu {
                ForEach(genFeedSwitchingFunctions()) { menuFunction in
                    MenuButton(menuFunction: menuFunction, confirmDestructive: nil) // no destructive feed switches
                }
            } label: {
                HStack(alignment: .center, spacing: 0) {
                    Text(feedType.label)
                        .font(.headline)
                    Image(systemName: Icons.dropdown)
                        .scaleEffect(0.7)
                }
                .foregroundColor(.primary)
                .accessibilityElement(children: .combine)
                .accessibilityHint("Activate to change feeds.")
                // this disables the implicit animation on the header view...
                .transaction { $0.animation = nil }
            }
        }
    }
}
