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
    @State var accessToken: String
    
    let communityName: String?
    let communityID: Int?

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
                        NavigationLink(destination: PostExpanded(instanceAddress: instanceAddress, accessToken: accessToken, post: post))
                        {
                            PostItem(post: post, isExpanded: false, instanceAddress: instanceAddress, accessToken: accessToken)
                                .environmentObject(isInSpecificCommunity)
                        }
                        .buttonStyle(.plain) // Make it so that the link doesn't mess with the styling
                        .task
                        {
                            if post == postTracker.posts.last
                            {
                                if communityID == nil
                                {
                                    await loadInfiniteFeed(postTracker: postTracker, appState: appState, instanceAddress: instanceAddress)
                                }
                                else
                                {
                                    await loadInfiniteFeed(postTracker: postTracker, appState: appState, instanceAddress: instanceAddress, communityName: communityName)
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(Color.secondarySystemBackground)
        .navigationTitle(communityName ?? instanceAddress.host!)
        .task(priority: .userInitiated, {
            
            if postTracker.posts.isEmpty
            {
                print("Post tracker is empty")
                
                await loadInfiniteFeed(postTracker: postTracker, appState: appState, instanceAddress: instanceAddress, communityName: communityName)
                
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
