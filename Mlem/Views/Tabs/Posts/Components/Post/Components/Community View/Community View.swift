//
//  Community View.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import SwiftUI

struct CommunityView: View
{
    @AppStorage("shouldShowCommunityHeaders") var shouldShowCommunityHeaders: Bool = false

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var filtersTracker: FiltersTracker
    @EnvironmentObject var communitySearchResultsTracker: CommunitySearchResultsTracker
    @EnvironmentObject var favoriteCommunitiesTracker: FavoriteCommunitiesTracker

    @Environment(\.isPresented) var isPresente

    @StateObject var postTracker: PostTracker = .init()

    @State var account: SavedAccount
    @State var community: APICommunity?
    @State var communityDetails: GetCommunityResponse?

    @State private var selectedSortingOption: SortingOptions = .hot

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

    enum FocusedNewPostField
    {
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
            ScrollView {
                if postTracker.posts.isEmpty {
                    noPostsView
                } else {
                    LazyVStack {
                        bannerView
                        postListView
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
                        )
                        { /// This is here to show the sidebar when needed
                            Text("")
                        }
                        .hidden()

                        VStack(alignment: .leading, spacing: 15)
                        {
                            VStack(alignment: .leading, spacing: 15)
                            {
                                HStack(alignment: .center, spacing: 10)
                                {
                                    TextField("New post title…", text: $newPostTitle, axis: .vertical)
                                        .textFieldStyle(.roundedBorder)
                                        .focused($focusedNewPostField, equals: .newPostTitle)

                                    if !newPostTitle.isEmpty
                                    {
                                        if !isPostingPost
                                        {
                                            Button
                                            {
                                                Task(priority: .userInitiated) {
                                                    isPostingPost = true

                                                    print("Will try to post comment")

                                                    defer
                                                    {
                                                        newPostTitle = ""
                                                        newPostURL = ""
                                                        newPostBody = ""
                                                        newPostIsNSFW = false

                                                        isPostingPost = false
                                                        focusedNewPostField = nil
                                                    }

                                                    do
                                                    {
                                                        try await postPost(to: community!, postTitle: newPostTitle, postBody: newPostBody, postURL: newPostURL, postIsNSFW: newPostIsNSFW, postTracker: postTracker, account: account, appState: appState)
                                                    }
                                                    catch let postPostingError
                                                    {
                                                        print("Failed while posting post: \(postPostingError)")
                                                    }
                                                }
                                            } label: {
                                                Image(systemName: "paperplane")
                                            }
                                        }
                                        else
                                        {
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

                    postTracker.page = 1 /// Reset the page so it doesn't load some page in the middle of the feed
                    postTracker.posts = .init()

                    await loadFeed()

                    isRefreshing = false
                }
            }
            .task(priority: .userInitiated)
            {
                if postTracker.posts.isEmpty
                {
                    print("Post tracker is empty")

                    if postTracker.posts.isEmpty
                    {
                        postTracker.isLoading = true
                    }

                    await loadFeed()

                    postTracker.isLoading = false
                }
                else
                {
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
            .onChange(of: feedType, perform: { newValue in
                Task(priority: .userInitiated) {
                    postTracker.page = 1

                    postTracker.posts = .init()
                    postTracker.isLoading = true

                    await loadFeed()

                    postTracker.isLoading = false
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
            ToolbarItem(placement: .principal)
            { /// This is here to replace the default navigationTitle and make it possible to tap it
                if !isShowingCommunitySearch
                {
                    HStack(alignment: .center, spacing: 0)
                    {
                        Text(community?.name ?? feedType.rawValue)
                            .font(.headline)
                        Image(systemName: "chevron.down")
                            .scaleEffect(0.7)
                    }
                    .onTapGesture
                    {
                        isSearchFieldFocused = true

                        withAnimation(Animation.interactiveSpring(response: 0.5, dampingFraction: 1, blendDuration: 0.5))
                        {
                            isShowingCommunitySearch.toggle()
                        }
                    }
                }
                else
                {
                    CommunitySearchField(isSearchFieldFocused: $isSearchFieldFocused, searchText: $searchText, account: account)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if !isShowingCommunitySearch {
                    SortingMenu(selectedSortingOption: Binding(
                        get: {
                            selectedSortingOption
                        },
                        set: { newValue in
                            self.selectedSortingOption = newValue
                            Task {
                                print("Selected sorting option: \(newValue), \(newValue.rawValue)")

                                postTracker.posts = .init()
                                postTracker.page = 1


                                if postTracker.posts.isEmpty {
                                    postTracker.isLoading = true
                                }

                                await loadFeed()
                                postTracker.isLoading = false

                            }
                        }
                    ))

                    Menu
                    {
                        if isInSpecificCommunity
                        {
                            Button
                            {
                                print("Will toggle sidebar")
                                isSidebarShown.toggle()
                                print("Sidebar value: \(isSidebarShown)")
                            } label: {
                                Label("Sidebar", systemImage: "sidebar.right")
                            }
                        }

                        Divider()

                        if let communityDetails
                        {
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

                            if favoriteCommunitiesTracker.favoriteCommunities.contains(where: { $0.community.id == community!.id })
                            { /// This is when a community is already favorited
                                Button(role: .destructive) {
                                    unfavoriteCommunity(account: account, community: community!, favoritedCommunitiesTracker: favoriteCommunitiesTracker)
                                } label: {
                                    Label("Unfavorite", systemImage: "star.slash")
                                }
                            }
                            else
                            {
                                Button {
                                    favoriteCommunity(account: account, community: community!, favoritedCommunitiesTracker: favoriteCommunitiesTracker)
                                } label: {
                                    Label("Favorite", systemImage: "star")
                                }
                                .tint(.yellow)
                            }

                            Divider()

                            if let actorId = community?.actorId {
                                ShareButton(
                                    urlToShare: actorId,
                                    isShowingButtonText: true
                                )
                            }
                        }
                        else
                        {
                            ShareButton(urlToShare: URL(string: "https://\(account.instanceLink.host!)")!, isShowingButtonText: true)
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis")
                    }
                } else {
                    Button
                    {
                        isSearchFieldFocused = false

                        withAnimation(Animation.interactiveSpring(response: 0.5, dampingFraction: 1, blendDuration: 0.5))
                        {
                            isShowingCommunitySearch.toggle()
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                        { /// Clear the search text and results one second after it disappears so it doesn't just disappear in the middle of the animation
                            searchText = ""
                            communitySearchResultsTracker.foundCommunities = .init()
                        }
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
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
            VStack(alignment: .leading, spacing: 5)
            {
                Text("Post body (Optional)")
                    .foregroundColor(.secondary)
                    .font(.caption)

                TextField("Unleash your inner author", text: $newPostBody, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedNewPostField, equals: .newPostBody)
            }

            VStack(alignment: .leading, spacing: 5)
            {
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
            NavigationLink(destination: PostExpanded(
                account: account,
                postTracker: postTracker,
                post: post,
                feedType: $feedType
            ))
            {
                PostItem(
                    postTracker: postTracker,
                    post: post,
                    isExpanded: false,
                    isInSpecificCommunity: isInSpecificCommunity,
                    account: account,
                    feedType: $feedType
                )
            }
            .buttonStyle(.plain) // Make it so that the link doesn't mess with the styling
            .task {
                if post == postTracker.posts.last {
                    if postTracker.posts.isEmpty {
                        postTracker.isLoading = true
                    }

                    await loadFeed()
                    postTracker.isLoading = false
                }
            }
        }
    }

    func loadFeed() async {
        do {
            try await loadInfiniteFeed(
                postTracker: postTracker,
                appState: appState,
                communityId: community?.id,
                feedType: feedType,
                sortingType: selectedSortingOption,
                account: account
            )
        } catch APIClientError.networking {
            errorAlert = .init(
                title: "Unable to connect to Lemmy",
                message: "Please check your internet connection and try again"
            )
        } catch APIClientError.response(let message, _) {
            errorAlert = .init(
                title: "Error",
                message: message.error
            )
        } catch {
            errorAlert = .unexpected
        }

    }
}
