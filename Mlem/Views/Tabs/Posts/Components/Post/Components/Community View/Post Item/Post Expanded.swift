//
//  Opened Post.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct PostExpanded: View
{
    @EnvironmentObject var appState: AppState
    
    @StateObject var commentTracker: CommentTracker = .init()
    
    @State var instanceAddress: URL
    
    @State var account: SavedAccount

    @State private var isReplySheetOpen: Bool = false
    @State private var sortSelection = 0
    
    let post: Post

    var body: some View
    {
        ScrollView
        {
            PostItem(post: post, isExpanded: true, isInSpecificCommunity: true, instanceAddress: instanceAddress, account: account)

            if post.numberOfComments == 0
            { // If there are no comments, just don't show anything
                VStack
                {
                    VStack
                    {
                        Image(systemName: "binoculars")
                            .aspectRatio(contentMode: .fill)
                        Text("No comments to be found")
                            .font(.headline)
                    }
                    Text("Why not post the first one?")
                        .font(.subheadline)
                }
                .foregroundColor(.secondary)
                .padding()
            }
            else
            { // Otherwise we'll have to do some actual work
                if commentTracker.isLoading
                {
                    LoadingView(whatIsLoading: .comments)
                        .task(priority: .userInitiated)
                        {
                            commentTracker.isLoading = true
                            
                            var commentCommand: String = ""
                            
                            if instanceAddress.absoluteString.contains("v1")
                            {
                                print("Older API spec")
                                
                                commentCommand = """
    {"op": "GetPost", "data": { "id": \(post.id) }}
    """
                            }
                            else
                            {
                                print("Newer API spec")
                                
                                commentCommand = """
{"op": "GetComments", "data": { "max_depth": 90, "post_id": \(post.id), "type_": "All" }}
"""
                            }
                            
                            let commentResponse: String = try! await sendCommand(maintainOpenConnection: false, instanceAddress: instanceAddress, command: commentCommand)
                            
                            print("Comment response: \(commentResponse)")
                            
                            commentTracker.comments = try! await parseComments(commentResponse: commentResponse, instanceLink: instanceAddress)
                            
                            commentTracker.isLoading = false
                        }
                }
                else
                {
                    LazyVStack(alignment: .leading, spacing: 15) {
                        ForEach(commentTracker.comments)
                        { comment in
                            CommentItem(comment: comment)
                        }
                    }
                }
            }
        }
        .navigationBarTitle(post.community.name, displayMode: .inline)
    }
}
