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

struct Community_View: View
{
    @EnvironmentObject var appState: AppState
    
    @StateObject var postTracker: PostTracker = .init()
    
    @State var instanceAddress: String
    
    let communityName: String
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
                Loading_View(whatIsLoading: .posts)
            }
            else
            {
                LazyVStack
                {
                    ForEach(postTracker.posts)
                    { post in
                        /*if post == posts.decodedPosts.last
                        {}*/
                        NavigationLink(destination: Post_Expanded(post: post))
                        {
                            Post_Item(post: post, isExpanded: false)
                                .environmentObject(isInSpecificCommunity)
                        }
                        .buttonStyle(.plain) // Make it so that the link doesn't mess with the styling
                        .task
                        {
                            if post == postTracker.posts.last
                            {
                                if communityID == nil
                                {
                                    await loadInfiniteFeed(postTracker: postTracker, appState: appState)
                                }
                                else
                                {
                                    await loadInfiniteFeed(postTracker: postTracker, appState: appState, communityName: communityName)
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(Color.secondarySystemBackground)
        .navigationTitle(communityName)
        .task(priority: .userInitiated, {
            
            appState.currentActiveInstance = instanceAddress
            
            if let communityID
            {
                await loadInfiniteFeed(postTracker: postTracker, appState: appState, communityName: communityName)
            }
            else
            {
                await loadInfiniteFeed(postTracker: postTracker, appState: appState)
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
            Search_Sheet()
        }
    }
}
