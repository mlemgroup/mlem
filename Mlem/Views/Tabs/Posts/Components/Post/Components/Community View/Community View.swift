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

    let community: Community?

    @State private var isSidebarShown: Bool = false

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

    @Environment(\.isPresented) var isPresented

    @State private var isShowingSearch: Bool = false

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
                                StickyImageView(url: community?.banner)
                            }
                        }
                    }

                    NavigationLink(destination: CommunitySidebarView(), isActive: $isSidebarShown)
                    { /// This is here to show the sidebar when needed
                        Text("")
                    }
                    .hidden()

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
                                    await loadInfiniteFeed(postTracker: postTracker, appState: appState, instanceAddress: instanceAddress, community: nil)
                                }
                                else
                                {
                                    await loadInfiniteFeed(postTracker: postTracker, appState: appState, instanceAddress: instanceAddress, community: post.community)
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(Color.secondarySystemBackground)
        .navigationTitle(community?.name ?? username)
        .navigationBarTitleDisplayMode(shouldShowCommunityHeaders ? .inline : .large)
        .task(priority: .userInitiated)
        {
            if postTracker.posts.isEmpty
            {
                print("Post tracker is empty")

                await loadInfiniteFeed(postTracker: postTracker, appState: appState, instanceAddress: instanceAddress, community: community)
            }
            else
            {
                print("Post tracker is not empty")
            }
        }
        .toolbar
        {
            Button
            {
                isShowingSearch.toggle()
            } label: {
                Image(systemName: "magnifyingglass")
            }

            Menu
            {
                #warning("TODO: Add a [submit post] feature")
                Button
                {
                    print("Submit post")
                } label: {
                    Label("Submit Post", systemImage: "plus.bubble")
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
            } label: {
                Label("More", systemImage: "info.circle")
            }
        }
        .sheet(isPresented: $isShowingSearch)
        {
            SearchSheet()
        }
    }
}
