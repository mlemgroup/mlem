//
//  Opened Post.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Post_Expanded: View {
    
    @ObservedObject var connectionHandler = LemmyConnectionHandler(instanceAddress: "hexbear.net")
    
    let post: Post
    
    var body: some View {
        ScrollView {
            Post_Item(postName: post.name, author: post.creatorName, communityName: post.communityName, communityLink: post.communityActorID, postBody: post.body, imageThumbnail: post.thumbnailURL, score: post.score, numberOfComments: post.numberOfComments, isExpanded: true)
            
            if connectionHandler.isLoading {
                ProgressView()
            } else {
                Text(connectionHandler.receivedData)
            }
            
        }
        .navigationBarTitle(post.communityName, displayMode: .inline)
        .onAppear {
            connectionHandler.sendCommand(maintainOpenConnection: false, command: """
            {"op": "GetPost", "data": {"id": \(post.id)}}
            """)
        }
        .onReceive(connectionHandler.$receivedData) { receivedData in
            print("Got this from the async call: \(receivedData)")
            print("==========")
            if receivedData == "" { // This is here because the function is called even when the ObservedObject is empty. Utterly retarded TODO: Make it more elegant so this shit actually works like it's supposed to
                print("LMAO empty")
            } else { // Only decipher the comments once there's actual data
                print("LMAO not empty")
                
                print("Finna decode")
                decodeRawCommentJSON(commentRawData: receivedData)
            }
        }
    }
}
