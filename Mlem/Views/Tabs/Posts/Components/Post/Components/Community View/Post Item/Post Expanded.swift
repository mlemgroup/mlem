//
//  Opened Post.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Post_Expanded: View
{
    @EnvironmentObject var appState: AppState
    
    @ObservedObject var connectionHandler = LemmyConnectionHandler(instanceAddress: "hexbear.net")
    
    @StateObject var commentTracker: CommentTracker = .init()

    @State private var isReplySheetOpen: Bool = false
    @State private var sortSelection = 0

    let post: Post

    var body: some View
    {
        ScrollView
        {
            Post_Item(post: post, isExpanded: true)

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
                    Loading_View(whatIsLoading: .comments)
                        .task(priority: .userInitiated)
                        {
                            commentTracker.isLoading = true
                            
                            let commentCommand: String = """
    {"op": "GetPost", "data": { "id": \(post.id) }}
    """
                            let commentResponse: String = try! await sendCommand(maintainOpenConnection: false, instanceAddress: appState.currentActiveInstance, command: commentCommand)
                            
                            print("Comment response: \(commentResponse)")
                            
                            commentTracker.comments = try! await parseComments(commentResponse: commentResponse)
                            
                            commentTracker.isLoading = false
                        }
                }
                else
                {
                    LazyVStack(alignment: .leading, spacing: 15) {
                        ForEach(commentTracker.comments)
                        { comment in
                            Comment_Item(comment: comment)
                        }
                    }
                }
            }
        }
        .navigationBarTitle(post.communityName, displayMode: .inline)
    }
}
