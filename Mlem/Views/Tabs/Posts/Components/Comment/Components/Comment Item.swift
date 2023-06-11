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
    
    @State var isCollapsed = false
    
    @State private var isShowingTextSelectionSheet: Bool = false

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            if hierarchicalComment.commentView.comment.deleted == true
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
                HStack
                {
                    HStack(alignment: .center, spacing: 2) {
                        Image(systemName: "arrow.up")
                        
                        Text(String(hierarchicalComment.commentView.counts.score))
                    }
                    .if(hierarchicalComment.commentView.myVote == .none || hierarchicalComment.commentView.myVote == .downvote)
                    { viewProxy in
                        viewProxy
                            .foregroundColor(.accentColor)
                    }
                    .if(hierarchicalComment.commentView.myVote == .upvote)
                    { viewProxy in
                        viewProxy
                            .foregroundColor(.green)
                    }
                    .onTapGesture {
                        Task(priority: .userInitiated) {
                            try await rate(hierarchicalComment, operation: .upvote)
                        }
                    }
                    
                    Image(systemName: "arrow.down")
                        .if(hierarchicalComment.commentView.myVote == .downvote)
                        { viewProxy in
                            viewProxy
                                .foregroundColor(.red)
                        }
                        .if(hierarchicalComment.commentView.myVote == .upvote || hierarchicalComment.commentView.myVote == .none)
                        { viewProxy in
                            viewProxy
                                .foregroundColor(.accentColor)
                        }
                        .onTapGesture {
                            Task(priority: .userInitiated) {
                                try await rate(hierarchicalComment, operation: .downvote)
                            }
                        }
                }

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

                Spacer()

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
                    Text(getTimeIntervalFromNow(date: hierarchicalComment.commentView.comment.published))
                    UserProfileLink(account: account, user: hierarchicalComment.commentView.creator)
                }
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
                        CommentItem(account: account, hierarchicalComment: comment)
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
        .dynamicTypeSize(.small)
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
    
    private func rate(_ comment: HierarchicalComment, operation: ScoringOperation) async throws {
        let operationToPerform: ScoringOperation?
        switch operation {
        case .upvote:
            operationToPerform = upvoteAction(for: comment.commentView.myVote)
        case .downvote:
            operationToPerform = downvoteAction(for: operation)
        default:
            operationToPerform = nil
            assertionFailure("unexpected case passed into function")
        }
        
        guard let operationToPerform else { return }
        
        let updatedComment = try await rateComment(
            comment: comment.commentView,
            operation: operationToPerform,
            account: account,
            commentTracker: commentTracker,
            appState: appState
        )
        
        if let updatedComment {
            await MainActor.run {
                self.hierarchicalComment = updatedComment
            }
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
