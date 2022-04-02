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
            Post_Item(postName: post.name, author: post.creatorName, communityName: post.communityName, communityLink: post.communityActorID, url: post.url, postBody: post.body, imageThumbnail: post.thumbnailURL, score: post.score, numberOfComments: post.numberOfComments, isExpanded: true)
            
            if post.numberOfComments == 0 { // If there are no comments, just don' show anything
                VStack {
                    VStack {
                        Image(systemName: "binoculars")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                        Text("No comments to be found")
                            .font(.headline)
                    }
                    Text("Why not post the first one?")
                        .font(.subheadline)
                }
                .foregroundColor(.secondary)
                .padding()
            } else { // Otherwise we'll have to do some actual work
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
                .onAppear { // Request the comments only if I'm actually expecting comments.
                    // If there are no comments, this won't fire
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
                
                if connectionHandler.isLoading {
                    Loading_View(whatIsLoading: .comments)
                } else {
                    //Text(connectionHandler.receivedData)
                    if comments.isLoading {
                        Loading_View(whatIsLoading: .comments)
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
            
        }
        .navigationBarTitle(post.communityName ?? "Undefined", displayMode: .inline)
    }
}
