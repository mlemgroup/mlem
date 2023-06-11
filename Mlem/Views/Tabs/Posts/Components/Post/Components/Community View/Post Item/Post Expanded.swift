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
    @StateObject var commentReplyTracker: CommentReplyTracker = .init()

    @State var account: SavedAccount

    @State var postTracker: PostTracker

    var post: APIPostView

    @State private var sortSelection = 0

    @State private var commentSortingType: CommentSortTypes = .top

    @FocusState var isReplyFieldFocused
    
    @Binding var feedType: FeedType

    @State private var textFieldContents: String = ""
    @State private var replyingToCommentID: Int? = nil

    @State private var isInTheMiddleOfStyling: Bool = false
    @State private var isPostingComment: Bool = false

    @State private var viewID: UUID = UUID()
    
    @State private var errorAlert: ErrorAlert?

    var body: some View
    {
        ScrollView
        {
            PostItem(postTracker: postTracker, post: post, isExpanded: true, isInSpecificCommunity: true, account: account, feedType: $feedType)

            if commentTracker.isLoading
            {
                ProgressView("Loading comments…")
                    .task(priority: .userInitiated)
                    {
                        if post.counts.comments != 0
                        {
                            await loadComments()
                        }
                        else
                        {
                            commentTracker.isLoading = false
                        }
                    }
                    .onAppear
                    {
                        commentSortingType = defaultCommentSorting
                    }
            }
            else
            {
                if commentTracker.comments.count == 0
                { // If there are no comments, just don't show anything
                    VStack(spacing: 2)
                    {
                        VStack(spacing: 5)
                        {
                            Image(systemName: "binoculars")
                                
                            Text("No comments to be found")
                        }
                        Text("Why not post the first one?")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    .padding()
                }
                else
                { // Otherwise we'll have to do some actual work
                    LazyVStack(alignment: .leading, spacing: 15)
                    {
                        ForEach(commentTracker.comments)
                        { comment in
                            CommentItem(account: account, hierarchicalComment: comment)
                        }
                    }
                    .environmentObject(commentTracker)
                }
            }
        }
        .environmentObject(commentReplyTracker)
        .navigationBarTitle(post.community.name, displayMode: .inline)
        .safeAreaInset(edge: .bottom)
        {
            VStack
            {
                if let commentToReplyTo = commentReplyTracker.commentToReplyTo {
                    HStack(alignment: .top)
                    {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(alignment: .center, spacing: 2) {
                                Text("Replying to \(commentToReplyTo.creator.name):")
                                    .font(.caption)
                                // UserProfileLink(shouldShowUserAvatars: true, user: commentToReplyTo.creator)
                            }
                            .foregroundColor(.secondary)
                            
                            Text(commentToReplyTo.comment.content)
                                .font(.system(size: 16))
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    Divider()
                }
                
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
                                if commentReplyTracker.commentToReplyTo == nil
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
                                            try await postComment(
                                                to: post,
                                                commentContents: textFieldContents,
                                                commentTracker: commentTracker,
                                                account: account,
                                                appState: appState
                                            )
                                            
                                            isReplyFieldFocused = false
                                            textFieldContents = ""
                                        }
                                        catch let commentPostingError
                                        {
                                            
                                            appState.alertTitle = "Couldn't post comment"
                                            appState.alertMessage = "An error occured when posting the comment.\nTry again later, or restart Mlem."
                                            appState.isShowingAlert.toggle()
                                            
                                            print("Failed while posting error: \(commentPostingError)")
                                        }
                                    }
                                }
                                else
                                {
                                    Task(priority: .userInitiated) {
                                        isPostingComment = true
                                        
                                        print("Will post reply")
                                        
                                        defer
                                        {
                                            isPostingComment = false
                                        }
                                        
                                        do
                                        {
                                            try await postComment(
                                                to: commentReplyTracker.commentToReplyTo!,
                                                post: post,
                                                commentContents: textFieldContents,
                                                commentTracker: commentTracker,
                                                account: account,
                                                appState: appState
                                            )
                                            
                                            commentReplyTracker.commentToReplyTo = nil
                                            isReplyFieldFocused = false
                                            textFieldContents = ""
                                        }
                                        catch let replyPostingError
                                        {                                            
                                            print("Failed while posting response: \(replyPostingError)")
                                        }
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
            .onChange(of: commentReplyTracker.commentToReplyTo) { newValue in
                if newValue != nil
                {
                    isReplyFieldFocused.toggle()
                }
            }
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

            ToolbarItemGroup(placement: .keyboard)
            {
                Spacer()

                Button
                {
                    isReplyFieldFocused = false
                    
                    if commentReplyTracker.commentToReplyTo != nil
                    {
                        commentReplyTracker.commentToReplyTo = nil
                    }
                } label: {
                    Text("Cancel")
                }
            }
        }
        .refreshable {
            Task(priority: .userInitiated) {
                commentTracker.comments = .init()
                await loadComments()
            }
        }
        .onChange(of: commentSortingType) { newSortingType in
            withAnimation(.easeIn(duration: 0.4)) {
                commentTracker.comments = sortComments(commentTracker.comments, by: newSortingType)
            }
        }
        .alert(using: $errorAlert) { content in
            Alert(title: Text(content.title), message: Text(content.message))
        }
    }

    func loadComments() async {
        defer { commentTracker.isLoading = false }
        
        commentTracker.isLoading = true
        do {
            let request = GetCommentsRequest(account: account, postId: post.id)
            let response = try await APIClient().perform(request: request)
            commentTracker.comments = sortComments(response.comments.hierarchicalRepresentation, by: defaultCommentSorting)
        } catch APIClientError.response(let message, _) {
            errorAlert = .init(title: "API error", message: message.error)
        } catch {
            errorAlert = .init(title: "Failed to load comments", message: "Please refresh to try again")
        }
    }

    private func sortComments(_ comments: [HierarchicalComment], by sort: CommentSortTypes) -> [HierarchicalComment]
    {
        let sortedComments: [HierarchicalComment]
        switch sort
        {
        case .new:
            sortedComments = comments.sorted(by: { $0.commentView.comment.published > $1.commentView.comment.published })
        case .top:
            sortedComments = comments.sorted(by: { $0.commentView.counts.score > $1.commentView.counts.score })
        case .active:
            sortedComments = comments.sorted(by: { $0.commentView.counts.childCount > $1.commentView.counts.childCount })
        }

        return sortedComments.map { comment in
            let newComment = comment
            newComment.children = sortComments(comment.children, by: sort)
            return newComment
        }
    }
}
