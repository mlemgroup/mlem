//
//  Community View.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import SwiftUI

struct Community_View: View {
    let communityName: String
    
    @ObservedObject var connectionHandler = LemmyConnectionHandler(instanceAddress: "hexbear.net")
    @ObservedObject var posts = PostData_Decoded()
    
    var body: some View {
        ScrollView {
            if posts.isLoading {
                Loading_View(whatIsLoading: .posts)
            } else {
                ForEach(posts.decodedPosts) { post in
                    NavigationLink(destination: Post_Expanded(post: post)) {
                        Post_Item(postName: post.name, author: post.creatorName, communityName: post.communityName, communityLink: post.communityActorID, url: post.url, postBody: post.body, imageThumbnail: post.thumbnailURL, score: post.score, numberOfComments: post.numberOfComments, isExpanded: false)
                    }
                    .buttonStyle(.plain) // Make it so that the link doesn't mess with the styling
                }
            }
        }
        .background(Color.secondarySystemBackground)
        .navigationTitle(communityName)
        .onAppear {
            connectionHandler.sendCommand(maintainOpenConnection: false, command: """
                {"op": "GetPosts", "data": {"type_": "All", "sort":"Hot"}}
                """)
        }
        .onReceive(connectionHandler.$receivedData) { receivedData in
            if receivedData != "" {
                print("Finna decode posts")
                posts.decodeRawPostJSON(postRawData: receivedData)
                
                // posts.pushPostsToStorage(decodedPostData: posts.decodedPosts)
            }
        }
    }
}
