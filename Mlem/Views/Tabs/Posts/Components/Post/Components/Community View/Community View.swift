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

    @StateObject var postTracker: PostTracker = .init()

    @State var instanceAddress: URL

    @State var account: SavedAccount
    @State var community: Community?

    @State private var selectedSortingOption: SortingOptions = .hot

    @State private var isSidebarShown: Bool = false
    @State private var isShowingCommunitySearch: Bool = false

    @State private var isRefreshing: Bool = false

    @State private var searchText: String = ""

    @FocusState var isSearchFieldFocused: Bool

    @State private var isComposingPost: Bool = false
    @State private var newPostTitle: String = ""
    @State private var newPostBody: String = ""
    @State private var newPostURL: String = ""
    @State private var newPostIsNSFW: Bool = false
    @State private var isPostingPost: Bool = false

    enum FocusedNewPostField
    {
        case newPostTitle, newPostBody, newPostURL
    }

    @FocusState var focusedNewPostField: FocusedNewPostField?

    var isInSpecificCommunity: Bool
    {
        if community == nil
        {
            return false
        }
        else
        {
            return true
        }
    }

    var body: some View
    {
        ZStack(alignment: .top)
        {
            CommunitySearchResultsView(instanceAddress: instanceAddress, account: account)
            // .transition(.move(edge: .top).combined(with: .opacity))

            ScrollView
            {
                if postTracker.posts.isEmpty
                {
                    LoadingView(whatIsLoading: .posts)
                }
                else
                {
                    LazyVStack
                    {
                        if isInSpecificCommunity
                        {
                            if shouldShowCommunityHeaders
                            {
                                if let communityBannerURL = community?.banner
                                {
                                    StickyImageView(url: communityBannerURL)
                                }
                            }
                        }

                        if isInSpecificCommunity
                        {
                            NavigationLink(destination: CommunitySidebarView(community: community!, isActive: $isSidebarShown), isActive: $isSidebarShown)
                            { /// This is here to show the sidebar when needed
                                Text("")
                            }
                            .hidden()
                        }

                        ForEach(postTracker.posts.filter { !$0.name.contains(filtersTracker.filteredKeywords) }) /// Filter out blocked keywords
                        { post in
                            NavigationLink(destination: PostExpanded(instanceAddress: instanceAddress, account: account, post: post))
                            {
                                PostItem(post: post, isExpanded: false, isInSpecificCommunity: isInSpecificCommunity, instanceAddress: instanceAddress, account: account)
                            }
                            .buttonStyle(.plain) // Make it so that the link doesn't mess with the styling
                            .task
                            {
                                if post == postTracker.posts.last
                                {
                                    if community == nil
                                    {
                                        await loadInfiniteFeed(postTracker: postTracker, appState: appState, instanceAddress: instanceAddress, community: nil, sortingType: selectedSortingOption)
                                    }
                                    else
                                    {
                                        await loadInfiniteFeed(postTracker: postTracker, appState: appState, instanceAddress: instanceAddress, community: post.community, sortingType: selectedSortingOption)
                                    }
                                }
                            }
                            .onChange(of: selectedSortingOption, perform: { newValue in
                                Task
                                {
                                    print("Selected sorting option: \(newValue), \(newValue.rawValue)")

                                    postTracker.posts = .init()
                                    postTracker.page = 1

                                    if community == nil
                                    {
                                        await loadInfiniteFeed(postTracker: postTracker, appState: appState, instanceAddress: instanceAddress, community: nil, sortingType: selectedSortingOption)
                                    }
                                    else
                                    {
                                        await loadInfiniteFeed(postTracker: postTracker, appState: appState, instanceAddress: instanceAddress, community: post.community, sortingType: selectedSortingOption)
                                    }
                                }
                            })
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom)
            {
                if isInSpecificCommunity
                {
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
                                            print("Ahoj")
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

                            if !newPostTitle.isEmpty
                            {
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
                                            .focused($focusedNewPostField, equals: .newPostURL)
                                    }
                                    
                                    Button
                                    {
                                        withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 1, blendDuration: 0.4))
                                        {
                                            isComposingPost = false
                                            newPostTitle = ""
                                            newPostBody = ""
                                            newPostURL = ""
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6)
                                        {
                                            focusedNewPostField = nil
                                        }

                                    } label: {
                                        Text("Cancel")
                                    }
                                }
                                .transition(.move(edge: .bottom).combined(with: .opacity))
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
            .background(Color.secondarySystemBackground)
            .offset(y: isShowingCommunitySearch ? 300 : 0)
            .refreshable
            {
                Task(priority: .userInitiated)
                {
                    isRefreshing = true

                    postTracker.page = 1 /// Reset the page so it doesn't load some page in the middle of the feed
                    postTracker.posts = .init()

                    await loadInfiniteFeed(postTracker: postTracker, appState: appState, instanceAddress: instanceAddress, community: community, sortingType: selectedSortingOption)

                    isRefreshing = false
                }
            }
            .task(priority: .userInitiated)
            {
                if postTracker.posts.isEmpty
                {
                    print("Post tracker is empty")

                    await loadInfiniteFeed(postTracker: postTracker, appState: appState, instanceAddress: instanceAddress, community: community, sortingType: selectedSortingOption)
                }
                else
                {
                    print("Post tracker is not empty")
                }
            }
            .task(priority: .background)
            {
                if isInSpecificCommunity
                {
                    do
                    {
                        community?.details = try await loadCommunityDetails(community: community!, instanceAddress: instanceAddress)
                    }
                    catch let communityDetailsFetchingError
                    {
                        print("Failed while fetching community details: \(communityDetailsFetchingError)")
                        appState.criticalErrorType = .shittyInternet
                        appState.isShowingCriticalError = true
                    }
                }
            }
            .toolbar
            {
                ToolbarItem(placement: .principal)
                { /// This is here to replace the default navigationTitle and make it possible to tap it
                    if !isShowingCommunitySearch
                    {
                        HStack(alignment: .center, spacing: 0)
                        {
                            Text(community?.name ?? "Home")
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
                        CommunitySearchField(isSearchFieldFocused: $isSearchFieldFocused, searchText: $searchText, instanceAddress: instanceAddress)
                    }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing)
                {
                    if !isShowingCommunitySearch
                    {
                        Menu
                        {
                            Button
                            {
                                selectedSortingOption = .active
                            } label: {
                                Label("Active", systemImage: "bubble.left.and.bubble.right")
                            }

                            Button
                            {
                                selectedSortingOption = .hot
                            } label: {
                                Label("Hot", systemImage: "flame")
                            }

                            Button
                            {
                                selectedSortingOption = .new
                            } label: {
                                Label("New", systemImage: "sun.max")
                            }

                            Menu
                            {
                                Button
                                {
                                    selectedSortingOption = .topDay
                                } label: {
                                    Label("Day", systemImage: "calendar.day.timeline.left")
                                }

                                Button
                                {
                                    selectedSortingOption = .topWeek
                                } label: {
                                    Label("Week", systemImage: "calendar.day.timeline.left")
                                }

                                Button
                                {
                                    selectedSortingOption = .topMonth
                                } label: {
                                    Label("Month", systemImage: "calendar.day.timeline.left")
                                }

                                Button
                                {
                                    selectedSortingOption = .topYear
                                } label: {
                                    Label("Year", systemImage: "calendar.day.timeline.left")
                                }

                                Button
                                {
                                    selectedSortingOption = .topAll
                                } label: {
                                    Label("All time", systemImage: "calendar.day.timeline.left")
                                }
                            } label: {
                                Label("Top…", systemImage: "text.line.first.and.arrowtriangle.forward")
                            }
                        } label: {
                            switch selectedSortingOption
                            {
                            case .active:
                                Label("Selected sorting by  \"Active\"", systemImage: "bubble.left.and.bubble.right")
                            case .hot:
                                Label("Selected sorting by \"Hot\"", systemImage: "flame")
                            case .new:
                                Label("Selected sorting by \"New\"", systemImage: "sun.max")
                            case .topDay:
                                Label("Selected sorting by \"Top of Day\"", systemImage: "calendar.day.timeline.left")
                            case .topWeek:
                                Label("Selected sorting by \"Top of Week\"", systemImage: "calendar.day.timeline.left")
                            case .topMonth:
                                Label("Selected sorting by \"Top of Month\"", systemImage: "calendar.day.timeline.left")
                            case .topYear:
                                Label("Selected sorting by \"Top of Year\"", systemImage: "calendar.day.timeline.left")
                            case .topAll:
                                Label("Selected sorting by \"Top of All Time\"", systemImage: "calendar.day.timeline.left")

                                #warning("TODO: Make this the default icon for the sorting")
                                /* case .unspecified:
                                 Label("Sort posts", systemImage: "arrow.up.and.down.text.horizontal") */
                            }
                        }

                        Menu
                        {
                            #warning("TODO: Add a [submit post] feature")
                            Button
                            {
                                print("Submit post")
                            } label: {
                                Label("Submit Post…", systemImage: "plus.bubble")
                            }

                            if isInSpecificCommunity
                            {
                                Button
                                {
                                    self.isSidebarShown = true
                                } label: {
                                    Label("Sidebar", systemImage: "sidebar.right")
                                }
                            }

                            Divider()

                            if isInSpecificCommunity
                            {
                                Button
                                {
                                    print("Would favorite community \(community!.name) for the user \(account.username)")
                                } label: {
                                    Label("Favorite", systemImage: "star")
                                }

                                ShareButton(urlToShare: community!.actorID, isShowingButtonText: true)
                            }
                            else
                            {
                                ShareButton(urlToShare: URL(string: "https://\(instanceAddress.host!)")!, isShowingButtonText: true)
                            }
                        } label: {
                            Label("More", systemImage: "info.circle")
                        }
                    }
                    else
                    {
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
    }
}
