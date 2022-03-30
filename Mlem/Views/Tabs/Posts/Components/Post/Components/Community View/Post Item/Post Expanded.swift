//
//  Opened Post.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Post_Expanded: View {
    
    @ObservedObject var connectionHandler = LemmyConnectionHandler(instanceAddress: "hexbear.net")
    @ObservedObject var comments = CommentData_Decoded()
    
    @State private var isReplySheetOpen: Bool = false
    @State private var sortSelection: String = "Best"
    
    let post: Post
    
    var body: some View {
        ScrollView {
            Post_Item(postName: post.name, author: post.creatorName, communityName: post.communityName, communityLink: post.communityActorID, postBody: post.body, imageThumbnail: post.thumbnailURL, score: post.score, numberOfComments: post.numberOfComments, isExpanded: true)
            HStack {
                Picker(selection: $sortSelection, label: Text(sortSelection)) {
                    // TODO: Implement sorting
                    
                    // TODO: Make it actually work. The @State does not update
                    Label("Best", systemImage: "star.fill")
                    Label("Hot", systemImage: "flame.fill")
                    Label("New", systemImage: "sun.max.fill")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Selected \(sortSelection)")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.secondarySystemBackground)
            
            if connectionHandler.isLoading {
                ProgressView()
            } else {
                //Text(connectionHandler.receivedData)
                if comments.isLoading {
                    ProgressView()
                } else {
                    VStack(spacing: 16) {
                        ForEach(comments.decodedComments) { comment in
                            Comment_Item(author: comment.creatorActorID, commentBody: comment.content!, commentID: comment.id!, score: comment.score!)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
        }
        .navigationBarTitle(post.communityName, displayMode: .inline)
        .onAppear {
            connectionHandler.sendCommand(maintainOpenConnection: false, command: """
            {"op": "GetPost", "data": {"id": \(post.id)}}
            """)
        }
        .onReceive(connectionHandler.$receivedData) { receivedData in
            if receivedData != "" { // This is here because the function is called even when the ObservedObject is empty. Utterly retarded TODO: Make it more elegant so this shit actually works like it's supposed to. Fuck
                print("LMAO not empty")
                
                print("Finna decode")
                comments.decodeRawCommentJSON(commentRawData: receivedData)
            }
        }
    }
}
