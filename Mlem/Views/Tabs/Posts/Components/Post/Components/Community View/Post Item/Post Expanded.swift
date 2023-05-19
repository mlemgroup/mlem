//
//  Opened Post.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct PostExpanded: View
{
    @AppStorage("defaultCommentSorting") var defaultCommentSorting: CommentSortTypes = .top

    @EnvironmentObject var appState: AppState

    @StateObject var commentTracker: CommentTracker = .init()

    @State var instanceAddress: URL

    @State var account: SavedAccount

    let post: Post

    @State private var isReplySheetOpen: Bool = false
    @State private var sortSelection = 0

    @State private var commentSortingType: CommentSortTypes = .top

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
                            await loadComments()
                        }
                        .onAppear
                        {
                            commentSortingType = defaultCommentSorting
                        }
                }
                else
                {
                    LazyVStack(alignment: .leading, spacing: 15)
                    {
                        ForEach(commentTracker.comments)
                        { comment in
                            CommentItem(comment: comment)
                        }
                    }
                }
            }
        }
        .navigationBarTitle(post.community.name, displayMode: .inline)
        .toolbar
        {
            ToolbarItemGroup(placement: .navigationBarTrailing)
            {
                Menu
                {
                    Button
                    {
                        commentSortingType = .active
                    } label: {
                        Label("Active", systemImage: "bubble.left.and.bubble.right")
                    }

                    Button
                    {
                        commentSortingType = .new
                    } label: {
                        Label("New", systemImage: "sun.max")
                    }

                    Button
                    {
                        commentSortingType = .top
                    } label: {
                        Label("Top", systemImage: "calendar.day.timeline.left")
                    }

                } label: {
                    switch commentSortingType
                    {
                    case .new:
                        Label("New", systemImage: "sun.max")
                    case .top:
                        Label("Top", systemImage: "calendar.day.timeline.left")
                    case .active:
                        Label("Active", systemImage: "bubble.left.and.bubble.right")
                    }
                }
            }
        }
        .refreshable
        {
            Task(priority: .userInitiated)
            {
                commentTracker.comments = .init()

                await loadComments()
            }
        }
        .onChange(of: commentSortingType) { newSortingType in
            withAnimation(.easeIn(duration: 0.5))
            {
                commentTracker.comments = sortComments(sortBy: newSortingType)
            }
        }
    }

    internal func loadComments() async
    {
        commentTracker.isLoading = true

        var commentCommand = ""

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

        var parsedComments: [Comment] = try! await parseComments(commentResponse: commentResponse, instanceLink: instanceAddress)

        commentTracker.comments = sortComments(comments: parsedComments, sortBy: defaultCommentSorting)
        
        commentTracker.isLoading = false
        
        parsedComments = .init()
    }

    internal func sortComments(comments: [Comment]? = nil, sortBy: CommentSortTypes) -> [Comment]
    {
        var unsortedComments: [Comment] = .init()
        
        /// This check has to be there, because during the initial load, the comment tracker is empty, and we have to use a forced array of comments instead
        if let comments
        {
            unsortedComments = comments
        }
        else
        {
            unsortedComments = commentTracker.comments
        }
        
        switch sortBy
        {
        case .new:
            return unsortedComments.sorted(by: { $0.published > $1.published })
        case .top:
            return unsortedComments.sorted(by: { $0.score > $1.score })
        case .active:
            return unsortedComments.sorted(by: { $0.children.count > $1.children.count })
        }
    }
}
