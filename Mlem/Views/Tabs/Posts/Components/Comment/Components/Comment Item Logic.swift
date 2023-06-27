//
//  Comment Item Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

import SwiftUI

extension CommentItem {
    func voteOnComment(inputOp: ScoringOperation) async {
        do {
            let operation = hierarchicalComment.commentView.myVote == inputOp ? ScoringOperation.resetVote : inputOp
            try await _ = rateComment(
                comment: hierarchicalComment.commentView,
                operation: operation,
                account: account,
                commentTracker: commentTracker,
                appState: appState
            )
        } catch {
            print("failed to vote!")
        }
    }
    
    func deleteComment() async {
        do {
            // TODO: rename this function and/or move `deleteComment` out of the global scope
            // to avoid having to explicitly refer to our own module
            try await _ = Mlem.deleteComment(
                comment: hierarchicalComment.commentView,
                account: account,
                commentTracker: commentTracker,
                appState: appState
            )
        } catch {
            print("failed to delete comment!")
        }
    }
    
    func upvote() async {
        // don't do anything if currently awaiting a vote response
        guard dirty else {
            // fake downvote
            switch displayedVote {
            case .upvote:
                dirtyVote = .resetVote
                dirtyScore = displayedScore - 1
            case .resetVote:
                dirtyVote = .upvote
                dirtyScore = displayedScore + 1
            case .downvote:
                dirtyVote = .upvote
                dirtyScore = displayedScore + 2
            }
            dirty = true

            // wait for vote
            await voteOnComment(inputOp: .upvote)

            // unfake downvote and restore state
            dirty = false
            return
        }
    }

    func downvote() async {
        // don't do anything if currently awaiting a vote response
        guard dirty else {
            // fake upvote
            switch displayedVote {
            case .upvote:
                dirtyVote = .downvote
                dirtyScore = displayedScore - 2
            case .resetVote:
                dirtyVote = .downvote
                dirtyScore = displayedScore - 1
            case .downvote:
                dirtyVote = .resetVote
                dirtyScore = displayedScore + 1
            }
            dirty = true

            // wait for vote
            await voteOnComment(inputOp: .downvote)

            // unfake upvote
            dirty = false
            return
        }
    }

    /**
     Sends a save request for the current post
     */
    func saveComment() async {
        guard dirty else {
            // fake save
            dirtySaved.toggle()
            dirty = true

            do {
                try await sendSaveCommentRequest(account: account,
                                                 commentId: hierarchicalComment.id,
                                                 save: dirtySaved,
                                                 commentTracker: commentTracker)
            } catch {
                print("failed to save comment!")
            }

            // unfake save
            dirty = false
            return
        }
    }

    @MainActor
    func replyToComment() {
        commentReplyTracker.commentToReplyTo = hierarchicalComment.commentView
    }
}
