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

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var filtersTracker: FiltersTracker
    @EnvironmentObject var communitySearchResultsTracker: CommunitySearchResultsTracker
    @EnvironmentObject var favoriteCommunitiesTracker: FavoriteCommunitiesTracker

    @StateObject var postTracker: PostTracker = .init()

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
    @State private var newPostTitle: String = ""
    @State private var newPostBody: String = ""
    @State private var newPostURL: String = ""
    @State private var newPostIsNSFW: Bool = false
    @State private var isPostingPost: Bool = false
    @State private var errorAlert: ErrorAlert?

    @State var isDragging: Bool = false

    enum FocusedNewPostField {
        case newPostTitle, newPostBody, newPostURL
    }

    @FocusState var focusedNewPostField: FocusedNewPostField?

    var isInSpecificCommunity: Bool { community != nil }

    private var filteredPosts: [APIPostView] {
        postTracker.posts.filter { postView in
            !postView.post.name.contains(filtersTracker.filteredKeywords)
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            searchResultsView
                .accessibilityHidden(!isShowingCommunitySearch)
            ScrollView {
                if postTracker.posts.isEmpty {
                    noPostsView
                } else {
                    LazyVStack(spacing: 0) {
                        bannerView
                        postListView
                        loadingMorePostsView
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if isInSpecificCommunity {
                    ZStack(alignment: .bottom) {
                        NavigationLink(
                            destination: CommunitySidebarView(
                                account: account,
                                communityDetails: $communityDetails,
                                isActive: $isSidebarShown
                            ),
                            isActive: $isSidebarShown
                        ) { /// This is here to show the sidebar when needed
                            Text("")
                        }
                        .hidden()

                        VStack(alignment: .leading, spacing: 15) {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack(alignment: .center, spacing: 10) {
                                    TextField("New post title…", text: $newPostTitle, axis: .vertical)
                                        .textFieldStyle(.roundedBorder)
                                        .focused($focusedNewPostField, equals: .newPostTitle)

                                    if !newPostTitle.isEmpty {
                                        if !isPostingPost {
                                            Button {
                                                Task(priority: .userInitiated) {
                                                    isPostingPost = true

                                                    print("Will try to post comment")

                                                    defer {
                                                        newPostTitle = ""
                                                        newPostURL = ""
                                                        newPostBody = ""
                                                        newPostIsNSFW = false

                                                        isPostingPost = false
                                                        focusedNewPostField = nil
                                                    }

                                                    do {
                                                        try await postPost(
                                                            to: community!,
                                                            postTitle: newPostTitle,
                                                            postBody: newPostBody,
                                                            postURL: newPostURL,
                                                            postIsNSFW: newPostIsNSFW,
                                                            postTracker: postTracker,
                                                            account: account
                                                        )
                                                    } catch let postPostingError {
                                                        print("Failed while posting post: \(postPostingError)")
                                                    }
                                                }
                                            } label: {
                                                Image(systemName: "paperplane")
                                            }
                                        } else {
                                            ProgressView()
                                        }
                                    }
                                }

                                if !newPostTitle.isEmpty {
                                    postInputView
                                }
                            }
                            .padding()

                            Divider()
                        }
                        .background(.regularMaterial)
                        .animation(.interactiveSpring(response: 0.4, dampingFraction: 1, blendDuration: 0.4), value: newPostTitle)
                        .animation(.interactiveSpring(response: 0.4, dampingFraction: 1, blendDuration: 0.4), value: newPostBody)
                        .animation(.interactiveSpring(response: 0.4, dampingFraction: 1, blendDuration: 0.4), value: newPostURL)
                    }
                }
            }
            .background(Color.secondarySystemBackground)
            .offset(y: isShowingCommunitySearch ? 300 : 0)
            .refreshable {
                Task(priority: .userInitiated) {
                    isRefreshing = true

                    postTracker.reset()

                    await loadFeed()

                    isRefreshing = false
                }
            }
            .task(priority: .userInitiated) {
                if postTracker.posts.isEmpty {
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
                    postTracker.reset()
                    await loadFeed()
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

                                postTracker.reset()
                                await loadFeed()
                            }
                        }
                    ))

                    Menu {
                        if isInSpecificCommunity {
                            Button {
                                print("Will toggle sidebar")
                                isSidebarShown.toggle()
                                print("Sidebar value: \(isSidebarShown)")
                            } label: {
                                Label("Sidebar", systemImage: "sidebar.right")
                            }
                        }

                        Divider()

                        if let communityDetails {
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

                            Divider()

                            if let actorId = community?.actorId {
                                ShareButton(size: 20, accessibilityContext: "community") {
                                    showShareSheet(URLtoShare: actorId)
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

    private var postInputView: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Post body (Optional)")
                    .foregroundColor(.secondary)
                    .font(.caption)

                TextField("Unleash your inner author", text: $newPostBody, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedNewPostField, equals: .newPostBody)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("Post URL (Optional)")
                    .foregroundColor(.secondary)
                    .font(.caption)

                TextField("https://corkmac.app", text: $newPostURL, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .focused($focusedNewPostField, equals: .newPostURL)
            }

        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
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
                    isDragging: $isDragging
                )
            }
            .buttonStyle(EmptyButtonStyle()) // Make it so that the link doesn't mess with the styling
            .task {
                if !postTracker.isLoading {
                    if let position = postTracker.posts.lastIndex(of: post) {
                        if  position >= (postTracker.posts.count - 40) {
                            await loadFeed()
                        }
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

    func loadFeed() async {
        do {
            try await postTracker.loadNextPage(
                account: account,
                communityId: community?.id,
                sort: postSortType,
                type: feedType
            )
        } catch APIClientError.networking {
            // TODO: we're seeing a number of SSL related errors on some instances while loading pages from the feed
            // while we investigate the reasons we will only show this error if the user would otherwise be left with an empty feed
            guard postTracker.posts.isEmpty else {
                return
            }

            errorAlert = .init(
                title: "Unable to connect to Lemmy",
                message: "Please check your internet connection and try again"
            )
        } catch APIClientError.response(let message, _) {
            errorAlert = .init(
                title: "Error",
                message: message.error
            )
        } catch APIClientError.cancelled {
            print("Failed while loading feed (request cancelled)")
        } catch {
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
