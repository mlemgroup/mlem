//
//  Feed View (new).swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-21.
//

import Dependencies
import Foundation
import SwiftUI

enum FeedTab: String, Identifiable, CaseIterable {
    
    var id: Self { self }
    case posts, about, moderators, statistics
}

// swiftlint:disable file_length
// swiftlint:disable type_body_length
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
    
    @Environment(\.navigationPathWithRoutes) private var navigationPath
    @Environment(\.scrollViewProxy) private var scrollViewProxy
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var filtersTracker: FiltersTracker
    @EnvironmentObject var editorTracker: EditorTracker
    
    // MARK: Parameters and init
    
    @State var community: CommunityModel?
    @State var feedType: FeedType
    @Binding var rootDetails: CommunityLinkWithContext?
    /// Applicable when presented as root view in a column of NavigationSplitView.
    @Binding var splitViewColumnVisibility: NavigationSplitViewVisibility
    
    @State var errorDetails: ErrorDetails?
    
    init(
        community: CommunityModel?,
        feedType: FeedType,
        rootDetails: Binding<CommunityLinkWithContext?>? = nil,
        splitViewColumnVisibility: Binding<NavigationSplitViewVisibility>? = nil
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
        
        self._rootDetails = rootDetails ?? .constant(nil)
        self._splitViewColumnVisibility = splitViewColumnVisibility ?? .constant(.automatic)
        self._community = State(initialValue: community)
        
        @AppStorage("fallbackDefaultPostSorting") var fallbackDefaultPostSorting: PostSortType = .hot
        _postSortType = .init(initialValue: fallbackDefaultPostSorting)
    }
    
    // MARK: State
    
    @StateObject var postTracker: PostTracker
    
    @State var postSortType: PostSortType
    @State var isLoading: Bool = true
    @State var shouldLoad: Bool = false
    
    @AppStorage("hasTranslucentInsets") var hasTranslucentInsets: Bool = true
    
    // MARK: Destructive confirmation
    
    @State private var isPresentingConfirmDestructive: Bool = false
    @State private var confirmationMenuFunction: StandardMenuFunction?
    
    func confirmDestructive(destructiveFunction: StandardMenuFunction) {
        confirmationMenuFunction = destructiveFunction
        isPresentingConfirmDestructive = true
    }
    
    @State var showNavigationTitle: Bool = false
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    private var scrollToTopId: Int? {
        postTracker.items.first?.id
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    // MARK: - Main Views
    
    var body: some View {
        contentView
            // .frame(maxWidth: .infinity, maxHeight: .infinity)
            // .background(hasTranslucentInsets ? Color.secondarySystemBackground : Color.systemBackground)
            .toolbar {
                ToolbarItem(placement: .principal) { toolbarHeader }
                ToolbarItem(placement: .navigationBarTrailing) { sortMenu }
                ToolbarItem(placement: .navigationBarTrailing) { ellipsisMenu }
            }
            .navigationBarTitleDisplayMode(.inline)
            // [2023.08] Set to `.visible` to workaround bug where navigation bar background may disappear on certain devices when device rotates.
            .navigationBarColor(visibility: .automatic)
            .hoistNavigation {
                if navigationPath.isEmpty {
                    /// Need to check `scrollToTopAppeared` because we want to scroll to top before popping back to sidebar. [2023.09]
                    if scrollToTopAppeared {
                        if horizontalSizeClass == .regular {
                            print("show/hide sidebar in regular size class")
                            splitViewColumnVisibility = {
                                if splitViewColumnVisibility == .all {
                                    return .detailOnly
                                } else {
                                    return .all
                                }
                            }()
                            return true
                        } else {
                            print("show/hide sidebar in compact size class")
                            // This seems a lot more reliable than dismiss action for some reason. [2023.09]
                            rootDetails = nil
                            return true
                            //                                // Return `false` to use dismiss action to go back to sidebar. Not sure
                            //                                return false
                        }
                    } else {
                        print("scroll to top")
                        withAnimation {
                            scrollViewProxy?.scrollTo(scrollToTop, anchor: .top)
                        }
                        return true
                    }
                } else {
                    if scrollToTopAppeared {
                        print("exhausted auxiliary actions, perform dismiss action instead...")
                        return false
                    } else {
                        withAnimation {
                            scrollViewProxy?.scrollTo(scrollToTop, anchor: .top)
                        }
                        return true
                    }
                }
            }
            .environmentObject(postTracker)
            .onAppear {
                if isLoading {
                    Task(priority: .userInitiated) {
                        setDefaultSortMode()
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
                    setDefaultSortMode()
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
            .onChange(of: postTracker.items) { newValue in
                if !newValue.isEmpty {
                    errorDetails = nil
                }
            }
            .refreshable {
                await refreshFeed()
            }
    }
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            if !postTracker.items.isEmpty {
                LazyVStack(spacing: 0) {
                    ScrollToView(appeared: $scrollToTopAppeared)
                        .id(scrollToTop)
                        .onAppear {
                            showNavigationTitle = false
                        }
                        .onDisappear {
                            showNavigationTitle = true
                        }
                    
                    if let community {
                        VStack(spacing: 5) {
                            HStack(alignment: .center, spacing: 10) {
                                AvatarView(community: community, avatarSize: 52)
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(community.displayName)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.01)
                                    if let fullyQualifiedName = community.fullyQualifiedName {
                                        Text(fullyQualifiedName)
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                if let subscribed = community.subscribed {
                                    let foregroundColor: Color = subscribed ? .green : .secondary
                                    Button {
                                        hapticManager.play(haptic: .lightSuccess, priority: .low)
                                        Task {
                                            var community = community
                                            do {
                                                try await community.toggleSubscribe { item in
                                                    DispatchQueue.main.async { self.community = item }
                                                }
                                            } catch {
                                                errorHandler.handle(error)
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text(abbreviateNumber(community.subscriberCount ?? 0))
                                            Image(systemName: subscribed ? Icons.successCircle : Icons.personFill)
                                                .aspectRatio(contentMode: .fit)
                                        }
                                        .foregroundStyle(foregroundColor)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 10)
                                        .background(
                                            Capsule()
                                                .strokeBorder(foregroundColor, style: .init(lineWidth: 1))
                                                .background(Capsule().fill(subscribed ? .green.opacity(0.1) : .clear))
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, AppConstants.postAndCommentSpacing)
                            Divider()
                            BubblePicker(FeedTab.allCases, selected: .constant(FeedTab.posts)) {
                                Text($0.rawValue.capitalized)
                            }
                        }
                        .padding(.top, -15)
                        .padding(.bottom, 5)
                        VStack(spacing: 15) {
                            Divider()
                            Divider()
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.secondarySystemBackground)
                    }
                    
                    // note: using .uid here because .id causes swipe actions to break--state changes still seem to properly trigger rerenders this way 🤔
                    ForEach(postTracker.items, id: \.uid) { post in
                        feedPost(for: post)
                    }
                    
                    // TODO: update to use proper LoadingState
                    EndOfFeedView(loadingState: isLoading && postTracker.page > 1 ? .loading : .done, viewType: .hobbit)
                }
                .padding(.top, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .overlay {
            if postTracker.items.isEmpty {
                noPostsView()
            }
        }
        .fancyTabScrollCompatible()
    }
    
    @ViewBuilder
    private func noPostsView() -> some View {
        VStack {
            if let errorDetails {
                ErrorView(errorDetails)
                    .frame(maxWidth: .infinity)
            } else if isLoading { // don't show posts until site information loads to avoid jarring redraw
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
            .transition(.opacity)
            .opacity(showNavigationTitle ? 1 : 0)
            .animation(.easeOut(duration: 0.2), value: showNavigationTitle)
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

// swiftlint:enable type_body_length
// swiftlint:enable file_length
