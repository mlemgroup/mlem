//
//  Comment View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct CommentItem: View
{
    @EnvironmentObject var commentReplyTracker: CommentReplyTracker
    @EnvironmentObject var commentTracker: CommentTracker
    
    @EnvironmentObject var appState: AppState
    
    @State var account: SavedAccount
    @State var hierarchicalComment: HierarchicalComment
    
    // Optional post context used to determin things
    // like if the person is OP or not
    @State var post: APIPostView? = nil
    
    @State var isCollapsed = false
    
    @State private var isShowingTextSelectionSheet: Bool = false
    @State private var localCommentScore: Int?
    @State private var localVote: ScoringOperation?
    
    /// The color to use on the upvote button depending on our current state
    private var upvoteColor: Color {
        let vote = localVote ?? hierarchicalComment.commentView.myVote
        // TODO: when the posts overhaul merge is in this should use the same value
        return vote == .upvote ? .green : .accentColor
    }
    
    /// The color to use on the downvote button depending on our current state
    private var downvoteColor: Color {
        let vote = localVote ?? hierarchicalComment.commentView.myVote
        // TODO: when the posts overhaul merge is in this should use the same value
        return vote == .downvote ? .red : .accentColor
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            if hierarchicalComment.commentView.comment.deleted
            {
                Text("Comment was deleted")
                    .italic()
                    .foregroundColor(.secondary)
            }
            else
            {
                if hierarchicalComment.commentView.comment.removed
                {
                    Text("Comment was removed")
                        .italic()
                        .foregroundColor(.secondary)
                }
                else
                {
                    if !isCollapsed
                    {
                        MarkdownView(text: hierarchicalComment.commentView.comment.content)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }

            HStack(spacing: 12)
            {
                #warning("TODO: Add post rating")
                VoteComplex(
                    vote: localVote ?? hierarchicalComment.commentView.myVote ?? .resetVote,
                    score: localCommentScore ?? hierarchicalComment.commentView.counts.score,
                    upvote: upvote,
                    downvote: downvote
                )

                HStack(spacing: 4)
                {
                    Button(action: {
                        print("Would reply to comment ID \(hierarchicalComment.id)")
                        
                        commentReplyTracker.commentToReplyTo = hierarchicalComment.commentView
                    }, label: {
                        Image(systemName: "arrowshape.turn.up.backward")
                    })

                    Text("Reply")
                        .foregroundColor(.accentColor)
                }
                .accessibilityAddTraits(.isButton)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Reply")

                Spacer()
                
                let relativeTime = getTimeIntervalFromNow(date: hierarchicalComment.commentView.comment.published)
                let creator = hierarchicalComment.commentView.creator.displayName ?? ""
                let commentorLabel = "Last updated \(relativeTime) ago by \(creator)"
                
                HStack
                {
                    #warning("TODO: Make the text selection work")
                    /*
                    Menu {
                        Button {
                            isShowingTextSelectionSheet.toggle()
                        } label: {
                            Label("Select text", systemImage: "selection.pin.in.out")
                        }

                    } label: {
                        Label("More Actions", systemImage: "ellipsis")
                            .labelStyle(.iconOnly)
                    }
                     */
                    Text(relativeTime)
                    UserProfileLink(account: account, user: hierarchicalComment.commentView.creator, postContext: post, commentContext: hierarchicalComment.commentView.comment)
                                    
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(commentorLabel)
                .foregroundColor(.secondary)
            }
            .disabled(isCollapsed)
            .onTapGesture {
                if isCollapsed
                {
                    withAnimation(Animation.interactiveSpring(response: 0.4, dampingFraction: 1, blendDuration: 0.4))
                    {
                        isCollapsed.toggle()
                    }
                }
            }
            
            Divider()

            if !isCollapsed
            {
                VStack(alignment: .leading, spacing: 10)
                {
                    ForEach(hierarchicalComment.children)
                    { comment in
                        CommentItem(account: account, hierarchicalComment: comment, post: post)
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .clipped()
            }
        }
        .clipped()
        .contentShape(Rectangle())
        .onTapGesture
        {
            withAnimation(Animation.interactiveSpring(response: 0.4, dampingFraction: 1, blendDuration: 0.4))
            {
                isCollapsed.toggle()
            }
        }
        .font(.body)
        .background(Color.systemBackground)
        .padding(hierarchicalComment.commentView.comment.parentId == nil ? .horizontal : .leading)
        .sheet(isPresented: $isShowingTextSelectionSheet) {
            NavigationView {
                VStack(alignment: .center, spacing: 0) {
                    Text(hierarchicalComment.commentView.comment.content)
                        .textSelection(.enabled)
                    Spacer()
                }
                .navigationTitle("Select text")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isShowingTextSelectionSheet.toggle()
                        } label: {
                            Text("Close")
                        }
                        
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
    
    private func upvote() async {
        try? await rate(hierarchicalComment, operation: .upvote)
    }
    
    private func downvote() async {
        try? await rate(hierarchicalComment, operation: .downvote)
    }
    
    private func rate(_ comment: HierarchicalComment, operation: ScoringOperation) async throws {
        guard localVote == nil else {
            // if we have a local vote then we're in the middle of rating
            // so avoid the user being able to initiate additional requests
            return
        }
        
        defer {
            // clear our 'faked' values after this function completes
            localVote = nil
            localCommentScore = nil
        }
        
        let operationToPerform: ScoringOperation?
        switch operation {
        case .upvote:
            operationToPerform = upvoteAction(for: comment.commentView.myVote)
        case .downvote:
            operationToPerform = downvoteAction(for: comment.commentView.myVote)
        default:
            operationToPerform = nil
            assertionFailure("unexpected case passed into function")
        }
        
        guard let operationToPerform else { return }
        
        adjustLocalState(for: operationToPerform)
        
        let updatedComment = try await rateComment(
            comment: comment.commentView,
            operation: operationToPerform,
            account: account,
            commentTracker: commentTracker,
            appState: appState
        )
        
        if let updatedComment {
            // if the rating succeeded update our genuine comment and clear the local state
            self.hierarchicalComment = updatedComment
        }
    }
    
    private func upvoteAction(for state: ScoringOperation?) -> ScoringOperation {
        switch state {
        case .upvote: return .resetVote
        case .resetVote, .downvote, .none: return .upvote
        }
    }
    
    private func downvoteAction(for state: ScoringOperation?) -> ScoringOperation {
        switch state {
        case .downvote: return .resetVote
        case .upvote, .resetVote, .none: return .downvote
        }
    }
}

private extension CommentItem {
    
    /// A method which adjusts our local state to reflect the expected outcome from the users rating
    /// - Parameter operation: The operation the user is performing, eg `.upvote`
    func adjustLocalState(for operation: ScoringOperation) {
        let currentVote = hierarchicalComment.commentView.myVote ?? .resetVote
        
        switch operation {
        // jump by two if we're going from one extreme to another...
        case .upvote where currentVote == .downvote:
            localCommentScore = hierarchicalComment.commentView.counts.score + 2
        case .downvote where currentVote == .upvote:
            localCommentScore = hierarchicalComment.commentView.counts.score - 2
        // jump by one for standard upvotes/downvotes
        // jump by one if we're resetting (user taps upvote while upvoted etc)
        case .upvote,
                .resetVote where currentVote == .downvote:
            localCommentScore = hierarchicalComment.commentView.counts.score + 1
        case .downvote,
                .resetVote where currentVote == .upvote:
            localCommentScore = hierarchicalComment.commentView.counts.score - 1
        // if we get a reset while we're already reset or have no vote recorded
        // then clear our local state as the API value is correct
        default:
            localVote = nil
            localCommentScore = nil
        }
        
        localVote = operation
    }
}
