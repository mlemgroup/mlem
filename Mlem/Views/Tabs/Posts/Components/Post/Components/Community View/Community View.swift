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
    let communityName: String
    let communityID: Int?

    @Environment(\.isPresented) var isPresented

    @ObservedObject var connectionHandler = LemmyConnectionHandler(instanceAddress: "hexbear.net")
    @ObservedObject var posts = PostData_Decoded()

    @StateObject var isInSpecificCommunity = IsInSpecificCommunity()

    @State private var isShowingSearch: Bool = false

    var body: some View
    {
        ScrollView
        {
            if posts.isLoading
            {
                Loading_View(whatIsLoading: .posts)
            }
            else
            {
                LazyVStack
                {
                    ForEach(posts.decodedPosts, id: \.id)
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
                            if post == posts.decodedPosts.last
                            {
                                if communityID == nil
                                {
                                    loadInfiniteFeed(connectionHandler: connectionHandler, tracker: posts)
                                }
                                else
                                {
                                    loadInfiniteFeed(connectionHandler: connectionHandler, tracker: posts, communityName: communityName)
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(Color.secondarySystemBackground)
        .navigationTitle(communityName)
        .onAppear
        {
            if communityID == nil
            { // If the community ID is nil, it means we want to pull all posts from that instance
                loadInfiniteFeed(connectionHandler: connectionHandler, tracker: posts)
            }
            else
            { // If there is a community ID, we want to pull posts from that specific community instead
                loadInfiniteFeed(connectionHandler: connectionHandler, tracker: posts, communityName: communityName)
            }
        }
        .onReceive(connectionHandler.$receivedData)
        { receivedData in
            if receivedData != ""
            {
                print("Finna decode posts")
                posts.decodeRawPostJSON(postRawData: receivedData)

                // posts.pushPostsToStorage(decodedPostData: posts.decodedPosts)
            }
        }
        .onDisappear
        {
            posts.latestLoadedPageCommunity = 0
        }
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
