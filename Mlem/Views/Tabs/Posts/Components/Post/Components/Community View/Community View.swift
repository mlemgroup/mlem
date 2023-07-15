//
//  Community View.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import SwiftUI

// swiftlint:disable file_length
// swiftlint:disable type_body_length
struct CommunityView: View {
    
    @AppStorage("shouldShowCommunityHeaders") var shouldShowCommunityHeaders: Bool = false
    @AppStorage("shouldHideNsfw") var shouldHideNsfw: Bool = true
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
    @AppStorage("shouldShowPostCreator") var shouldShowPostCreator: Bool = true
    @AppStorage("postSize") var postSize: PostSize = .headline

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var filtersTracker: FiltersTracker
    @EnvironmentObject var communitySearchResultsTracker: CommunitySearchResultsTracker
    @EnvironmentObject var favoriteCommunitiesTracker: FavoriteCommunitiesTracker

    @StateObject var postTracker: PostTracker = .init(shouldPerformMergeSorting: false)
    
    // parameters
    var community: APICommunity?
    @State var feedType: FeedType
    
    // variables
    @State var communityDetails: GetCommunityResponse?

    @State private var postSortType: PostSortType = .hot
    @State private var didLoad: Bool = false

    @State private var isRefreshing: Bool = false

    @State private var isComposingPost: Bool = false
    @State private var isPostingPost: Bool = false

    @State var isDragging: Bool = false
    @State var replyingToPost: APIPostView?
    
    private let scrollToTopId = "top"

    var isInSpecificCommunity: Bool { community != nil }
    
    init(community: APICommunity?, feedType: FeedType) {
        self.community = community
        self._feedType = State(initialValue: feedType)
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollViewReader { scrollProxy in
                ScrollView(showsIndicators: false) {
                    EmptyView().id(scrollToTopId) // 🙄
                    if postTracker.items.isEmpty {
                        noPostsView
                    } else {
                        LazyVStack(spacing: 0) {
                            bannerView
                            postListView
                            loadingMorePostsView
                        }
                    }
                }
                .background(Color.secondarySystemBackground)
                .refreshable {
                    Task(priority: .userInitiated) {
                        isRefreshing = true
                        defer { isRefreshing = false }
                        await refreshFeed()
                    }
                }
                .onAppear {
                    Task(priority: .userInitiated) {
                        if postTracker.items.isEmpty {
                            print("Post tracker is empty")
                            await loadFeed()
                        } else {
                            print("Post tracker is not empty")
                        }
                    }
                    Task(priority: .background) {
                        if isInSpecificCommunity, let community {
                            do {
                                communityDetails = try await loadCommunityDetails(
                                    community: community,
                                    account: appState.currentActiveAccount
                                )
                            } catch {
                                print("Failed while fetching community details: \(error)")
                                
                                appState.contextualError = .init(
                                    title: "Could not load community information",
                                    message: "The server might be overloaded.\nTry again later.",
                                    underlyingError: error
                                )
                            }
                        }
                    }
                }
                .onChange(of: feedType) { _ in
                    Task(priority: .userInitiated) {
                        await refreshFeed()
                        scrollProxy.scrollTo(scrollToTopId, anchor: .top)
                    }
                }
                .onChange(of: postSortType) { _ in
                    Task(priority: .userInitiated) {
                        await refreshFeed()
                        scrollProxy.scrollTo(scrollToTopId, anchor: .top)
                    }
                }
                .onChange(of: appState.currentActiveAccount) { _ in
                    Task {
                        await refreshFeed()
                        scrollProxy.scrollTo(scrollToTopId, anchor: .top)
                    }
                }
            }
        }
        .sheet(item: $replyingToPost) { post in
            GeneralCommentComposerView(
                replyTo: ReplyToFeedPost(appState: appState, post: post)
            )
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let community = community {
                    NavigationLink(value:
                                    CommunitySidebarLinkWithContext(
                                        community: community,
                                        communityDetails: communityDetails
                                    )) {
                                        Text(community.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .accessibilityHint("Activate to view sidebar.")
                                    }
                } else {
                    Menu {
                        feedTypeMenuItem(for: .subscribed)
                        feedTypeMenuItem(for: .local)
                        feedTypeMenuItem(for: .all)
                    } label: {
                        HStack(alignment: .center, spacing: 0) {
                            Text(feedType.label)
                                .font(.headline)
                            Image(systemName: "chevron.down")
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
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                PostSortMenu(selectedSortingOption: Binding(
                    get: {
                        postSortType
                    },
                    set: { newValue in
                        self.postSortType = newValue
                    }
                ))
                
                Menu {
                    if let specificCommunity = community {
                        NavigationLink(value:
                                        CommunitySidebarLinkWithContext(
                                            community: specificCommunity,
                                            communityDetails: communityDetails
                                        )) {
                                            Label("Sidebar", systemImage: "sidebar.right")
                                        }
                        
                        Button {
                            isComposingPost.toggle()
                        } label: {
                            Label("New Post", systemImage: "paperplane.fill")
                        }
                    }
                    Divider()
                    if let communityDetails {
                        
                        if favoriteCommunitiesTracker.favoriteCommunities.contains(where: { $0.community.id == community!.id }) {
                            // This is when a community is already favorited
                            Button(role: .destructive) {
                                unfavoriteCommunity(
                                    community: community!,
                                    favoritedCommunitiesTracker: favoriteCommunitiesTracker
                                )
                            } label: {
                                Label("Unfavorite", systemImage: "star.slash")
                            }
                        } else {
                            Button {
                                favoriteCommunity(
                                    account: appState.currentActiveAccount,
                                    community: community!,
                                    favoritedCommunitiesTracker: favoriteCommunitiesTracker
                                )
                            } label: {
                                Label("Favorite", systemImage: "star")
                            }
                            .tint(.yellow)
                        }
                        
                        SubscribeButton(
                            communityDetails: Binding(
                                get: {
                                    communityDetails.communityView
                                },
                                set: { newValue in
                                    guard let newValue else { return }
                                    self.communityDetails?.communityView = newValue
                                })
                        )
                        
                        BlockCommunityButton(communityDetails: Binding(
                            get: {
                                communityDetails.communityView
                            },
                            set: { newValue in
                                guard let newValue else { return }
                                self.communityDetails?.communityView = newValue
                            }))
                        
                        Divider()
                        
                        if let actorId = community?.actorId {
                            Button {
                                showShareSheet(URLtoShare: actorId)
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        }
                    }
                    
                    Button {
                        shouldBlurNsfw.toggle()
                    } label: {
                        if shouldBlurNsfw {
                            Label("Unblur NSFW", systemImage: "eye.trianglebadge.exclamationmark")
                        } else {
                            Label("Blur NSFW", systemImage: "eye.trianglebadge.exclamationmark")
                        }
                    }
                    
                    Menu {
                        if postSize != .compact {
                            Button {
                                postSize = .compact
                            } label: {
                                Label("Compact", systemImage: "rectangle.compress.vertical")
                            }
                        }
                        
                        if postSize != .headline {
                            Button {
                                postSize = .headline
                            } label: {
                                Label("Headline", systemImage: "rectangle")
                            }
                        }
                        
                        if postSize != .large {
                            Button {
                                postSize = .large
                            } label: {
                                Label("Large", systemImage: "rectangle.expand.vertical")
                            }
                        }
                    } label: {
                        Label("Post size", systemImage: "rectangle.compress.vertical")
                    }
                    .foregroundColor(.primary)
                } label: {
                    Label("More", systemImage: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $isComposingPost) {
            if let community = community {
                PostComposerView(community: community)
            }
        }
        .onAppear {
            if !didLoad {
                didLoad = true
                postSortType = defaultPostSorting
            }
        }
        .environmentObject(postTracker)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func feedTypeMenuItem(for setFeedType: FeedType) -> some View {
        Button {
            feedType = setFeedType
        } label: {
            if feedType == setFeedType {
                Label(setFeedType.label, systemImage: "checkmark")
            } else {
                Text(setFeedType.label)
            }
        }
    }

    @ViewBuilder
    private var noPostsView: some View {
        if postTracker.isLoading {
            LoadingView(whatIsLoading: .posts)
        } else {
            VStack(alignment: .center, spacing: 5) {
                Image(systemName: "text.bubble")

                Text("No posts to be found")
            }
            .padding()
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var bannerView: some View {
        if isInSpecificCommunity {
            if shouldShowCommunityHeaders {
                if let communityBannerURL = community?.banner {
                    StickyImageView(url: communityBannerURL)
                }
            }
        }
    }

    private var postListView: some View {
        ForEach(postTracker.items, id: \.id) { post in
            VStack(spacing: 0) {
                NavigationLink(value: PostLinkWithContext(post: post, postTracker: postTracker)) {
                    FeedPost(
                        postView: post,
                        showPostCreator: shouldShowPostCreator,
                        showCommunity: !isInSpecificCommunity,
                        isDragging: $isDragging,
                        replyToPost: replyToPost
                    )
                }
                Divider()
            }
            .buttonStyle(EmptyButtonStyle()) // Make it so that the link doesn't mess with the styling
            .onAppear {
                Task(priority: .medium) {
                    if postTracker.shouldLoadContent(after: post) {
                        await loadFeed()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var loadingMorePostsView: some View {
        if postTracker.isLoading {
            VStack(alignment: .center) {
                ProgressView()
                    .frame(width: 16, height: 16)
                Text("Loading more posts...")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(.secondary)
            .background(Color.systemBackground)
            .accessibilityElement(children: .combine)
        }
    }

    func replyToPost(replyTo: APIPostView) {
        replyingToPost = replyTo
    }

    func loadFeed() async {
        do {
            try await postTracker.loadNextPage(
                account: appState.currentActiveAccount,
                communityId: community?.id,
                sort: postSortType,
                type: feedType,
                filtering: { postView in
                    // post name doesn't contain a filtered keyword
                    !postView.post.name.contains(filtersTracker.filteredKeywords) &&
                    // post is not NSFW, if NSFW is hidden
                    !(shouldHideNsfw && (postView.post.nsfw || postView.community.nsfw))
                }
            )
        } catch {
            handle(error)
        }
    }

    func refreshFeed() async {
        do {
            try await postTracker.refresh(
                account: appState.currentActiveAccount,
                communityId: community?.id,
                sort: postSortType,
                type: feedType,
                filtering: { postView in
                    !postView.post.name.contains(filtersTracker.filteredKeywords)
                }
            )
        } catch {
            handle(error)
        }
    }

    private func handle(_ error: Error) {
        let title: String?
        let errorMessage: String?
        
        switch error {
        case APIClientError.networking:
            guard postTracker.items.isEmpty else {
                return
            }
            
        title = "Unable to connect to Lemmy"
        errorMessage = "Please check your internet connection and try again"
        default:
            title = nil
            errorMessage = nil
        }
        
        appState.contextualError = .init(
            title: title,
            message: errorMessage,
            underlyingError: error
        )
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable file_length
