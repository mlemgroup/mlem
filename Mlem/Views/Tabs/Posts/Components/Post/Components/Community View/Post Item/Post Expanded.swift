//
//  Opened Post.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

internal enum PossibleStyling
{
    case bold, italics
}

struct PostExpanded: View
{
    @AppStorage("defaultCommentSorting") var defaultCommentSorting: CommentSortTypes = .top

    @EnvironmentObject var appState: AppState

    @StateObject var commentTracker: CommentTracker = .init()

    @State var account: SavedAccount

    @State var postTracker: PostTracker
    
    let post: Post

    @State private var isReplySheetOpen: Bool = false
    @State private var sortSelection = 0

    @State private var commentSortingType: CommentSortTypes = .top

    @FocusState var isReplyFieldFocused

    @State private var textFieldContents: String = ""
    @State private var replyingToCommentID: Int? = nil

    @State private var isInTheMiddleOfStyling: Bool = false
    @State private var isPostingComment: Bool = false
    
    @State private var isShowingError: Bool = false

    var body: some View
    {
        ScrollView
        {
            PostItem(postTracker: postTracker, post: post, isExpanded: true, isInSpecificCommunity: true, account: account)

            if commentTracker.comments.count == 0
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
        .safeAreaInset(edge: .bottom)
        {
            VStack
            {
                HStack(alignment: .center, spacing: 10)
                {
                    TextField("Reply to post", text: $textFieldContents, prompt: Text("\(account.username):"), axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .focused($isReplyFieldFocused)

                    if !textFieldContents.isEmpty
                    {
                        if !isPostingComment
                        {
                            Button
                            {
                                Task(priority: .userInitiated)
                                {
                                    isPostingComment = true

                                    print("Will post comment")

                                    defer
                                    {
                                        isPostingComment = false
                                    }

                                    do
                                    {
                                        try await postComment(to: post, commentContents: textFieldContents, commentTracker: commentTracker, account: account)
                                        
                                        isReplyFieldFocused = false
                                        textFieldContents = ""
                                    }
                                    catch let commentPostingError
                                    {
                                        isShowingError = true
                                        print("Failed while posting error: \(commentPostingError)")
                                    }
                                }
                            } label: {
                                Image(systemName: "paperplane")
                            }
                        }
                        else
                        {
                            ProgressView()
                        }
                    }
                }
                .padding()

                Divider()
            }
            .background(.regularMaterial)
            .animation(.interactiveSpring(response: 0.4, dampingFraction: 1, blendDuration: 0.4), value: textFieldContents)
        }
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

            ToolbarItemGroup(placement: .keyboard) {
                
                Spacer()
                
                Button {
                    isReplyFieldFocused = false
                } label: {
                    Text("Cancel")
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
        .onChange(of: commentSortingType)
        { newSortingType in
            withAnimation(.easeIn(duration: 0.4))
            {
                commentTracker.comments = sortComments(commentTracker.comments, by: newSortingType)
            }
        }
        .alert(isPresented: $isShowingError) {
            Alert(title: Text("Could not post comment"), message: Text("An error occured when posting the comment.\nTry again later, or restart Mlem"), dismissButton: .default(Text("Close"), action: {
                isShowingError.toggle()
            }))
        }
    }

    internal func loadComments() async
    {
        commentTracker.isLoading = true

        var commentCommand = ""

        if account.instanceLink.absoluteString.contains("v1")
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

        let commentResponse: String = try! await sendCommand(maintainOpenConnection: false, instanceAddress: account.instanceLink, command: commentCommand)

        print("Comment response: \(commentResponse)")

        var parsedComments: [Comment] = try! await parseComments(commentResponse: commentResponse, instanceLink: account.instanceLink)

        commentTracker.comments = sortComments(parsedComments, by: defaultCommentSorting)

        commentTracker.isLoading = false

        parsedComments = .init()
    }

    private func sortComments(_ comments: [Comment], by sort: CommentSortTypes) -> [Comment]
    {
        let sortedComments: [Comment]
        switch sort
        {
        case .new:
            sortedComments = comments.sorted(by: { $0.published > $1.published })
        case .top:
            sortedComments = comments.sorted(by: { $0.score > $1.score })
        case .active:
            sortedComments = comments.sorted(by: { $0.children.count > $1.children.count })
        }

        return sortedComments.map { comment in
            var newComment = comment
            newComment.children = sortComments(comment.children, by: sort)
            return newComment
        }
    }
}
