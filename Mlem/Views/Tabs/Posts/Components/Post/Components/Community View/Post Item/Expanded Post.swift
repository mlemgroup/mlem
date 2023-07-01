//
//  Opened Post.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

internal enum PossibleStyling {
    case bold, italics
}

// swiftlint:disable type_body_length
// swiftlint:disable file_length
struct ExpandedPost: View {
    // appstorage
    @AppStorage("defaultCommentSorting") var defaultCommentSorting: CommentSortType = .top
    @AppStorage("shouldShowUserServerInComment") var shouldShowUserServerInComment: Bool = false

    @EnvironmentObject var appState: AppState

    @StateObject var commentTracker: CommentTracker = .init()
    @StateObject var commentReplyTracker: CommentReplyTracker = .init()

    @State var account: SavedAccount

    @EnvironmentObject var postTracker: PostTracker

    @State var post: APIPostView

    @State private var sortSelection = 0

    @State private var commentSortingType: CommentSortType = .top

    @FocusState var isReplyFieldFocused

    @Binding var feedType: FeedType

    @State private var textFieldContents: String = ""
    @State private var replyingToCommentID: Int?

    @State private var isInTheMiddleOfStyling: Bool = false
    @State private var isPostingComment: Bool = false

    @State private var viewID: UUID = UUID()

    @State private var errorAlert: ErrorAlert?

    @State var isDragging: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                postView
                
                Divider()
                    .background(.black)

                if commentTracker.isLoading {
                    commentsLoadingView
                } else {
                    if commentTracker.comments.count == 0 {
                        noCommentsView
                    } else {
                        commentsView
                    }
                }
            }
        }
        .scrollDisabled(isDragging)
        .environmentObject(commentReplyTracker)
        .navigationBarTitle(post.community.name, displayMode: .inline)
        .safeAreaInset(edge: .bottom) {
            VStack {
                if let commentToReplyTo = commentReplyTracker.commentToReplyTo {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(alignment: .center, spacing: 2) {
                                Text("Replying to ")
                                UserProfileLabel(
                                    shouldShowUserAvatars: false,
                                    account: account,
                                    user: commentToReplyTo.creator,
                                    showServerInstance: shouldShowUserServerInComment,
                                    postContext: post,
                                    commentContext: commentToReplyTo.comment,
                                    communityContext: nil
                                )
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

                HStack(alignment: .center, spacing: 10) {
                    TextField(
                        "Reply to post",
                        text: $textFieldContents,
                        prompt: Text("Commenting as \(account.username):"),
                        axis: .vertical
                    )
                    .textFieldStyle(.roundedBorder)
                    .focused($isReplyFieldFocused)
                    
                    if !textFieldContents.isEmpty {
                        if !isPostingComment {
                            Button {
                                if commentReplyTracker.commentToReplyTo == nil {
                                    Task(priority: .userInitiated) {
                                        isPostingComment = true

                                        print("Will post comment")
                                        defer {
                                            isPostingComment = false
                                        }

                                        do {
                                            try await postComment(
                                                to: post,
                                                commentContents: textFieldContents,
                                                commentTracker: commentTracker,
                                                account: account,
                                                appState: appState
                                            )

                                            isReplyFieldFocused = false
                                            textFieldContents = ""
                                        } catch let commentPostingError {
                                            appState.alertTitle = "Couldn't post comment"
                                            appState.alertMessage = "An error occured when posting the comment.\nTry again later."
                                            appState.isShowingAlert.toggle()

                                            print("Failed while posting error: \(commentPostingError)")
                                        }
                                    }
                                } else {
                                    Task(priority: .userInitiated) {
                                        isPostingComment = true

                                        print("Will post reply")

                                        defer {
                                            isPostingComment = false
                                        }

                                        do {
                                            try await postComment(
                                                to: commentReplyTracker.commentToReplyTo!,
                                                post: post,
                                                commentContents: textFieldContents,
                                                commentTracker: commentTracker,
                                                account: account
                                            )

                                            commentReplyTracker.commentToReplyTo = nil
                                            isReplyFieldFocused = false
                                            textFieldContents = ""
                                        } catch let replyPostingError {
                                            print("Failed while posting response: \(replyPostingError)")
                                        }
                                    }
                                }

                            } label: {
                                Image(systemName: "paperplane")
                            }
                        } else {
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
                if newValue != nil {
                    isReplyFieldFocused.toggle()
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    ForEach(CommentSortType.allCases, id: \.self) { type in
                        Button {
                            commentSortingType = type
                        } label: {
                            Label(type.description, systemImage: type.imageName)
                        }
                        .disabled(type == commentSortingType)
                    }

                } label: {
                    Label(commentSortingType.description, systemImage: commentSortingType.imageName)
                }
            }

            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button {
                    isReplyFieldFocused = false

                    if commentReplyTracker.commentToReplyTo != nil {
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
    // subviews

    /**
     Displays the post itself, plus a little divider to keep it visually distinct from comments
     */
    private var postView: some View {
        VStack(alignment: .leading, spacing: AppConstants.postAndCommentSpacing) {
            
            CommunityLinkView(community: post.community)
            
            LargePost(
                postView: post,
                account: account,
                isExpanded: true
            )
            
            UserProfileLink(account: account, user: post.creator, showServerInstance: true)
            
            PostInteractionBar(postView: post,
                               account: account,
                               menuFunctions: genMenuFunctions(),
                               voteOnPost: voteOnPost,
                               updatedSavePost: savePost,
                               deletePost: deletePost)
        }
        .padding(AppConstants.postAndCommentSpacing)
    }

    /**
     Displays a loading indicator for the comments
     */
    private var commentsLoadingView: some View {
        ProgressView("Loading comments…")
            .padding(.top, AppConstants.postAndCommentSpacing)
            .task(priority: .userInitiated) {
                if post.counts.comments != 0 {
                    await loadComments()
                } else {
                    commentTracker.isLoading = false
                }
            }
            .onAppear {
                commentSortingType = defaultCommentSorting
            }
    }

    /**
     Displays a "no comments" message
     */
    private var noCommentsView: some View {
        VStack(spacing: 2) {
            VStack(spacing: 5) {
                Image(systemName: "binoculars")
                Text("No comments to be found")
            }
            Text("Why not post the first one?")
                .font(.caption)
        }
        .foregroundColor(.secondary)
        .padding()
    }

    /**
     Displays the comments
     */
    private var commentsView: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(commentTracker.comments) { comment in
                CommentItem(
                    account: account,
                    hierarchicalComment: comment,
                    postContext: post,
                    depth: 0,
                    showPostContext: false,
                    showCommentCreator: true,
                    isDragging: $isDragging
                )
            }
        }
        .environmentObject(commentTracker)
    }

    // helper functions

    func loadComments() async {
        defer { commentTracker.isLoading = false }

        commentTracker.isLoading = true
        do {
            let request = GetCommentsRequest(account: account, postId: post.post.id)
            let response = try await APIClient().perform(request: request)
            commentTracker.comments = sortComments(response.comments.hierarchicalRepresentation, by: defaultCommentSorting)
        } catch APIClientError.response(let message, _) {
            errorAlert = .init(title: "API error", message: message.error)
        } catch {
            errorAlert = .init(title: "Failed to load comments", message: "Please refresh to try again")
        }
    }

    private func sortComments(_ comments: [HierarchicalComment], by sort: CommentSortType) -> [HierarchicalComment] {
        let sortedComments: [HierarchicalComment]
        switch sort {
        case .new:
            sortedComments = comments.sorted(by: { $0.commentView.comment.published > $1.commentView.comment.published })
        case .old:
            sortedComments = comments.sorted(by: { $0.commentView.comment.published < $1.commentView.comment.published })
        case .top:
            sortedComments = comments.sorted(by: { $0.commentView.counts.score > $1.commentView.counts.score })
        case .hot:
            sortedComments = comments.sorted(by: { $0.commentView.counts.childCount > $1.commentView.counts.childCount })
        }

        return sortedComments.map { comment in
            let newComment = comment
            newComment.children = sortComments(comment.children, by: sort)
            return newComment
        }
    }

    /// Votes on a post
    /// - Parameter inputOp: The voting operation to perform
    func voteOnPost(inputOp: ScoringOperation) async {
        do {
            let operation = post.myVote == inputOp ? ScoringOperation.resetVote : inputOp
            self.post = try await ratePost(
                postId: post.post.id,
                operation: operation,
                account: account,
                postTracker: postTracker,
                appState: appState
            )
        } catch {
            print("failed to vote!")
        }
    }
    
    /**
     Sends a save request for the current post
     */
    func savePost(_ save: Bool) async throws {
        self.post = try await sendSavePostRequest(account: account, postId: post.post.id, save: save, postTracker: postTracker)
    }
    
    func deletePost() async {
        do {
            // TODO: renamed this function and/or move `deleteComment` out of the global scope to avoid
            // having to refer to our own module
            _ = try await Mlem.deletePost(postId: post.post.id, account: account, postTracker: postTracker, appState: appState)
        } catch {
            print("failed to delete post: \(error)")
        }
    }
    
    // swiftlint:disable function_body_length
    func genMenuFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        // upvote
        let (upvoteText, upvoteImg) = post.myVote == .upvote ?
        ("Undo upvote", "arrow.up.square.fill") :
        ("Upvote", "arrow.up.square")
        ret.append(MenuFunction(
            text: upvoteText,
            imageName: upvoteImg,
            destructiveActionPrompt: nil,
            enabled: true) {
            Task(priority: .userInitiated) {
                await voteOnPost(inputOp: .upvote)
            }
        })
        
        // downvote
        let (downvoteText, downvoteImg) = post.myVote == .downvote ?
        ("Undo downvote", "arrow.down.square.fill") :
        ("Downvote", "arrow.down.square")
        ret.append(MenuFunction(
            text: downvoteText,
            imageName: downvoteImg,
            destructiveActionPrompt: nil,
            enabled: true) {
            Task(priority: .userInitiated) {
                await voteOnPost(inputOp: .downvote)
            }
        })
        
        // save
        let (saveText, saveImg) = post.saved ? ("Unsave", "bookmark.slash") : ("Save", "bookmark")
        ret.append(MenuFunction(
            text: saveText,
            imageName: saveImg,
            destructiveActionPrompt: nil,
            enabled: true) {
            Task(priority: .userInitiated) {
                try await savePost(_: !post.saved)
            }
        })
        
        // reply
        ret.append(MenuFunction(
            text: "Reply",
            imageName: "arrowshape.turn.up.left",
            destructiveActionPrompt: nil,
            enabled: true) {
            isReplyFieldFocused = true
        })
        
        // delete
        if post.creator.id == account.id {
            ret.append(MenuFunction(
                text: "Delete",
                imageName: "trash",
                destructiveActionPrompt: "Are you sure you want to delete this post?  This cannot be undone.",
                enabled: !post.post.deleted) {
                Task(priority: .userInitiated) {
                    await deletePost()
                }
            })
        }
        
        // share
        ret.append(MenuFunction(
            text: "Share",
            imageName: "square.and.arrow.up",
            destructiveActionPrompt: nil,
            enabled: true) {
            if let url = URL(string: post.post.apId) {
                showShareSheet(URLtoShare: url)
            }
        })
        
        return ret
    }
    // swiftlint:enable function_body_length
}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
