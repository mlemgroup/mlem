//
//  Community View.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import SwiftUI

class IsInSpecificCommunity: ObservableObject
{
    @Published var isInSpecificCommunity: Bool = false
}

struct CommunityView: View
{
    @EnvironmentObject var appState: AppState
    
    @StateObject var postTracker: PostTracker = .init()
    
    @State var instanceAddress: URL
    
    @State var username: String
    @State var accessToken: String
    
    let community: Community?

    @Environment(\.isPresented) var isPresented

    @StateObject var isInSpecificCommunity = IsInSpecificCommunity()
    
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
                    ForEach(postTracker.posts)
                    { post in
                        /*if post == posts.decodedPosts.last
                        {}*/
                        NavigationLink(destination: PostExpanded(instanceAddress: instanceAddress, username: username, accessToken: accessToken, post: post))
                        {
                            PostItem(post: post, isExpanded: false, instanceAddress: instanceAddress, username: username, accessToken: accessToken)
                                .environmentObject(isInSpecificCommunity)
                        }
                        .buttonStyle(.plain) // Make it so that the link doesn't mess with the styling
                        .task
                        {
                            if post == postTracker.posts.last
                            {
                                if community == nil
                                {
                                    await loadInfiniteFeed(postTracker: postTracker, appState: appState, instanceAddress: instanceAddress, community: post.community)
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
        .task(priority: .userInitiated, {
            
            if postTracker.posts.isEmpty
            {
                print("Post tracker is empty")
                
                await loadInfiniteFeed(postTracker: postTracker, appState: appState, instanceAddress: instanceAddress, community: community)
                
            }
            else
            {
                print("Post tracker is not empty")
            }
        })
        .toolbar
        {
            Button
            {
                isShowingSearch.toggle()
            } label: {
                Image(systemName: "magnifyingglass")
            }
        }
        .sheet(isPresented: $isShowingSearch)
        {
            SearchSheet()
        }
    }
}
