//
//  Community View.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import SwiftUI

struct Community_View: View {
    let mockCommunity: String = "Cool Lions"
    
    @ObservedObject var connectionHandler = LemmyConnectionHandler(instanceAddress: "hexbear.net")
    @ObservedObject var posts = PostData_Decoded()
    
    var body: some View {
        let communityName: String = mockCommunity
        ScrollView {
            if posts.isLoading {
                ProgressView()
            } else {
                ForEach(posts.decodedPosts) { post in
                    NavigationLink(destination: Post_Expanded(post: post)) {
                        Post_Item(postName: post.name, author: post.creatorName ?? "Undefined", communityName: post.communityName ?? "Undefined", communityLink: post.communityActorID ?? "Undefined", postBody: post.body, imageThumbnail: post.thumbnailURL, score: post.score ?? 69, numberOfComments: post.numberOfComments ?? 69, isExpanded: false)
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
                
                posts.pushPostsToStorage(decodedPostData: posts.decodedPosts)
            }
        }
    }
}

struct Community_View_Previews: PreviewProvider {
    static var previews: some View {
        Community_View()
    }
}
