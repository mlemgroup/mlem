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
    @AppStorage("shouldShowCompactPosts") var shouldShowCompactPosts: Bool = false
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
    @AppStorage("shouldShowPostCreator") var shouldShowPostCreator: Bool = true

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var filtersTracker: FiltersTracker
    @EnvironmentObject var communitySearchResultsTracker: CommunitySearchResultsTracker
    @EnvironmentObject var favoriteCommunitiesTracker: FavoriteCommunitiesTracker

    @StateObject var postTracker: PostTracker = .init(shouldPerformMergeSorting: false)

    @State var account: SavedAccount
    @State var community: APICommunity?
    @State var communityDetails: GetCommunityResponse?

    @State private var postSortType: PostSortType = .hot
    @State private var didLoad: Bool = false

    @State private var isSidebarShown: Bool = false
    @State private var isShowingCommunitySearch: Bool = false

    @State private var isRefreshing: Bool = false

    @State private var searchText: String = ""

    @FocusState var isSearchFieldFocused: Bool

    @State var feedType: FeedType = .subscribed

    @State private var isComposingPost: Bool = false
    @State private var isPostingPost: Bool = false
    @State private var errorAlert: ErrorAlert?

    @State var isDragging: Bool = false

    var isInSpecificCommunity: Bool { community != nil }

    private var filteredPosts: [APIPostView] {
        postTracker.items.filter { postView in
            !postView.post.name.contains(filtersTracker.filteredKeywords)
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            searchResultsView
                .accessibilityHidden(!isShowingCommunitySearch)
            ScrollView(showsIndicators: false) {
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
            .offset(y: isShowingCommunitySearch ? 300 : 0)
            .refreshable {
                Task(priority: .userInitiated) {
                    isRefreshing = true

                    try await postTracker.refresh(
                        account: account,
                        communityId: community?.id,
                        sort: postSortType,
                        type: feedType
                    )

                    isRefreshing = false
                }
            }
            .task(priority: .userInitiated) {
                if postTracker.items.isEmpty {
                    print("Post tracker is empty")
                    await loadFeed()
                } else {
                    print("Post tracker is not empty")
                }
            }
            .task(priority: .background) {
                if isInSpecificCommunity, let community {
                    do {
                        communityDetails = try await loadCommunityDetails(
                            community: community,
                            account: account,
                            appState: appState
                        )
                    } catch let communityDetailsFetchingError {
                        print("Failed while fetching community details: \(communityDetailsFetchingError)")

                        appState.alertTitle = "Could not load community information"
                        appState.alertMessage = "The server might be overloaded.\nTry again later."
                        appState.isShowingAlert.toggle()
                    }
                }
            }
            .onChange(of: feedType, perform: { _ in
                Task(priority: .userInitiated) {
                    await refreshFeed()
                }
            })
        }
        .alert(using: $errorAlert) { content in
            Alert(
                title: Text(content.title),
                message: Text(content.message)
            )
        }
        .toolbar {
            ToolbarItem(placement: .principal) { /// This is here to replace the default navigationTitle and make it possible to tap it
                if !isShowingCommunitySearch {
                    HStack(alignment: .center, spacing: 0) {
                        Text(community?.name ?? feedType.rawValue)
                            .font(.headline)
                        Image(systemName: "chevron.down")
                            .scaleEffect(0.7)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(community?.name ?? feedType.rawValue)")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityHint("Activate to search and select feeds")
                    .onTapGesture {
                        isSearchFieldFocused = true

                        withAnimation(Animation.interactiveSpring(response: 0.5, dampingFraction: 1, blendDuration: 0.5)) {
                            isShowingCommunitySearch.toggle()
                        }

                    }
                } else {
                    CommunitySearchField(isSearchFieldFocused: $isSearchFieldFocused, searchText: $searchText, account: account)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Search for communities.")
                        .accessibilityAddTraits(.isSearchField)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if !isShowingCommunitySearch {
                    PostSortMenu(selectedSortingOption: Binding(
                        get: {
                            postSortType
                        },
                        set: { newValue in
                            self.postSortType = newValue
                            Task {
                                print("Selected sorting option: \(newValue), \(newValue.rawValue)")
                                await refreshFeed()
                            }
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
                                        account: account,
                                        community: community!,
                                        favoritedCommunitiesTracker: favoriteCommunitiesTracker
                                    )
                                } label: {
                                    Label("Unfavorite", systemImage: "star.slash")
                                }
                            } else {
                                Button {
                                    favoriteCommunity(
                                        account: account,
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
                                    }),
                                account: account
                            )
                            
                            BlockCommunityButton(account: account, communityDetails: Binding(
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

                        Button {
                            shouldShowCompactPosts.toggle()
                        } label: {
                            if shouldShowCompactPosts {
                                Label("Large posts", systemImage: "rectangle.expand.vertical")
                            } else {
                                Label("Compact posts", systemImage: "rectangle.compress.vertical")
                            }
                        }
                        .foregroundColor(.primary)
                    } label: {
                        Label("More", systemImage: "ellipsis")
                    }
                } else {
                    Button {
                        isSearchFieldFocused = false

                        withAnimation(
                            .interactiveSpring(
                                response: 0.5,
                                dampingFraction: 1,
                                blendDuration: 0.5
                            )
                        ) {
                            isShowingCommunitySearch.toggle()
                        }

                        // clear the search text and results one second after it disappears
                        // so it doesn't just disappear in the middle of the animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            searchText = ""
                            communitySearchResultsTracker.foundCommunities = .init()
                        }
                    } label: {
                        Text("Cancel")
                    }
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
        
    }

    private var searchResultsView: some View {
        CommunitySearchResultsView(
            account: account,
            community: community,
            feedType: $feedType,
            isShowingSearch: $isShowingCommunitySearch
        )
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
        ForEach(filteredPosts) { post in
            NavigationLink(value: PostLinkWithContext(post: post, postTracker: postTracker, feedType: $feedType)) {
                FeedPost(
                    postView: post,
                    account: account,
                    showPostCreator: shouldShowPostCreator,
                    showCommunity: !isInSpecificCommunity,
                    isDragging: $isDragging
                )
            }
            .buttonStyle(EmptyButtonStyle()) // Make it so that the link doesn't mess with the styling
            .task {
                if postTracker.shouldLoadContent(after: post) {
                    await loadFeed()
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

    func loadFeed() async {
        do {
            try await postTracker.loadNextPage(
                account: account,
                communityId: community?.id,
                sort: postSortType,
                type: feedType
            )
        } catch {
            handle(error)
        }
    }
    
    func refreshFeed() async {
        do {
            try await postTracker.refresh(
                account: account,
                communityId: community?.id,
                sort: postSortType,
                type: feedType
            )
        } catch {
            handle(error)
        }
    }
    
    private func handle(_ error: Error) {
        switch error {
        case APIClientError.networking:
            // TODO: we're seeing a number of SSL related errors on some instances while loading pages from the feed
            // while we investigate the reasons we will only show this error if the user would otherwise be left with an empty feed
            guard postTracker.items.isEmpty else {
                return
            }
            
            errorAlert = .init(
                title: "Unable to connect to Lemmy",
                message: "Please check your internet connection and try again"
            )
        case APIClientError.response(let message, _):
            errorAlert = .init(
                title: "Error",
                message: message.error
            )
        case APIClientError.cancelled:
            print("Failed while loading feed (request cancelled)")
        default:
            // TODO: we may be receiving decoding errors (or something else) based on reports in the dev chat
            // for now we will fail silently if the user has posts to view while we investigate further
            assertionFailure(
                "Unhandled error encountered, if you can reproduce this please raise a ticket/discuss in the dev chat"
            )
            // errorAlert = .unexpected
        }
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable file_length
