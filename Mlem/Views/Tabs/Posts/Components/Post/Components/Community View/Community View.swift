//
//  Community View.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import SwiftUI

class IsInSpecificCommunity: ObservableObject {
    @Published var isInSpecificCommunity: Bool = false
}

struct Community_View: View {
    let communityName: String
    let communityID: Int?
    
    @ObservedObject var connectionHandler = LemmyConnectionHandler(instanceAddress: "hexbear.net")
    @ObservedObject var posts = PostData_Decoded()
    
    @StateObject var isInSpecificCommunity = IsInSpecificCommunity()
    
    @State private var isShowingSearch: Bool = false
    
    var body: some View {
        ScrollView {
            if posts.isLoading {
                Loading_View(whatIsLoading: .posts)
            } else {
                ForEach(posts.decodedPosts) { post in
                    NavigationLink(destination: Post_Expanded(post: post)) {
                        Post_Item(postName: post.name, author: post.creatorName, communityName: post.communityName, communityID: post.communityID, url: post.url, postBody: post.body, imageThumbnail: post.thumbnailURL, urlToPost: post.apID, score: post.score, numberOfComments: post.numberOfComments, timePosted: post.published, isStickied: post.stickied!, isExpanded: false)
                            .environmentObject(isInSpecificCommunity)
                    }
                    .buttonStyle(.plain) // Make it so that the link doesn't mess with the styling
                }
            }
        }
        .background(Color.secondarySystemBackground)
        .navigationTitle(communityName)
        .onAppear {
            if communityID == nil { // If the community ID is nil, it means we want to pull all posts from that instance
                connectionHandler.sendCommand(maintainOpenConnection: false, command: """
                    {"op": "GetPosts", "data": {"type_": "All", "sort":"Hot"}}
                    """)
            } else { // If there is a community ID, we want to pull posts from that specific community instead
                isInSpecificCommunity.isInSpecificCommunity = true // Set the Environment Object to true so the posts don't have community links when the user is already viewing a community
                
                connectionHandler.sendCommand(maintainOpenConnection: false, command: """
                {"op": "GetPosts", "data": {"type_": "Community", "sort": "Hot", "community_name": "\(communityName)"}}
                """) // TODO: For now, I have to put in the community name because the ID just straight-up doesn't work. Do something about it.
            }
        }
        .onReceive(connectionHandler.$receivedData) { receivedData in
            if receivedData != "" {
                print("Finna decode posts")
                posts.decodeRawPostJSON(postRawData: receivedData)
                
                // posts.pushPostsToStorage(decodedPostData: posts.decodedPosts)
            }
        }
        .toolbar {
            Button {
                isShowingSearch.toggle()
            } label: {
                Image(systemName: "magnifyingglass")
            }

        }
        .sheet(isPresented: $isShowingSearch) {
            Search_Sheet()
        }
    }
}
