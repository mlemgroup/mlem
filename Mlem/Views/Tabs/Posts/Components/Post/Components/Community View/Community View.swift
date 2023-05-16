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

    @StateObject var postTracker: PostTracker = .init()

    @State var instanceAddress: URL

    @State var username: String
    @State var accessToken: String

    @State var community: Community?

    @State private var selectedSortingOption: SortingOptions = .active

    @State private var isSidebarShown: Bool = false
    @State private var isShowingCommunitySearch: Bool = false
    
    @State private var searchText: String = ""
    
    @FocusState var isSearchFieldFocused: Bool

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
                        /* if post == posts.decodedPosts.last
                         {} */
                        NavigationLink(destination: PostExpanded(instanceAddress: instanceAddress, username: username, accessToken: accessToken, post: post))
                        {
                            PostItem(post: post, isExpanded: false, isInSpecificCommunity: isInSpecificCommunity, instanceAddress: instanceAddress, username: username, accessToken: accessToken)
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
        .background(Color.secondarySystemBackground)
        .overlay(alignment: .top)
        {
            if isShowingCommunitySearch
            {
                CommunitySearchView()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding()
                    .onChange(of: searchText) { newValue in
                        print("Search text: \(newValue)")
                    }
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
                    .onTapGesture {
                        isSearchFieldFocused.toggle()
                        
                        print("search field focus: \(isSearchFieldFocused)")
                        
                        withAnimation(Animation.interactiveSpring(response: 0.5, dampingFraction: 1, blendDuration: 0.5)) {
                            isShowingCommunitySearch.toggle()
                        }
                    }
                }
                else
                {
                    CommunitySearchField(isSearchFieldFocused: $isSearchFieldFocused, searchText: $searchText)
                }
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
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
                    Button {
                        withAnimation(Animation.interactiveSpring(response: 0.5, dampingFraction: 1, blendDuration: 0.5)) {
                            isShowingCommunitySearch.toggle()
                        }
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}
