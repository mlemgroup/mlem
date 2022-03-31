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
    @State private var sortSelection = 0
    
    let post: Post
    
    var body: some View {
        ScrollView {
            Post_Item(postName: post.name, author: post.creatorName ?? "Undefined", communityName: post.communityName ?? "Undefined", communityLink: post.communityActorID ?? "Undefined", postBody: post.body, imageThumbnail: post.thumbnailURL, score: post.score ?? 69, numberOfComments: post.numberOfComments ?? 69, isExpanded: true)
            HStack {
                Picker("Sort by", selection: $sortSelection) {
                    // TODO: Implement sorting
                    
                    // TODO: Make it actually work. The @State does not update
                    Label("Best", systemImage: "star.fill").tag(0)
                    Label("Hot", systemImage: "flame.fill").tag(1)
                    Label("New", systemImage: "sun.max.fill").tag(2)
                }              
                Spacer()

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
                            Comment_Item(author: comment.creatorName, commentBody: comment.content!, commentID: comment.id!, score: comment.score!)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
        }
        .navigationBarTitle(post.communityName ?? "Undefined", displayMode: .inline)
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
