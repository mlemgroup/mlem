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
                commentId: hierarchicalComment.commentView.id,
                operation: operation,
                account: appState.currentActiveAccount,
                commentTracker: commentTracker,
                appState: appState
            )
        } catch {
            appState.contextualError = .init(underlyingError: error)
        }
    }
    
    func deleteComment() async {
        do {
            // TODO: rename this function and/or move `deleteComment` out of the global scope
            // to avoid having to explicitly refer to our own module
            try await _ = Mlem.deleteComment(
                comment: hierarchicalComment.commentView,
                account: appState.currentActiveAccount,
                commentTracker: commentTracker,
                appState: appState
            )
        } catch {
            appState.contextualError = .init(underlyingError: error)
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
     Asynchronous wrapper around replyToComment so that it can be used in swipey actions
     */
    func replyToCommentAsyncWrapper() async {
        if let replyCallback = replyToComment {
            replyCallback(hierarchicalComment.commentView)
        }
    }
    
    func replyToCommentUnwrapped() {
        if let replyCallback = replyToComment {
            replyCallback(hierarchicalComment.commentView)
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
                try await sendSaveCommentRequest(account: appState.currentActiveAccount,
                                                 commentId: hierarchicalComment.id,
                                                 save: dirtySaved,
                                                 commentTracker: commentTracker)
            } catch {
                appState.contextualError = .init(underlyingError: error)
            }

            // unfake save
            dirty = false
            return
        }
    }

//    @MainActor
//    func replyToComment() {
//        commentReplyTracker.commentToReplyTo = hierarchicalComment.commentView
//    }
    
    // MARK: helpers
    
    // swiftlint:disable function_body_length
    func genMenuFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        // upvote
        let (upvoteText, upvoteImg) = hierarchicalComment.commentView.myVote == .upvote ?
        ("Undo upvote", "arrow.up.square.fill") :
        ("Upvote", "arrow.up.square")
        ret.append(MenuFunction(
            text: upvoteText,
            imageName: upvoteImg,
            destructiveActionPrompt: nil,
            enabled: true) {
            Task(priority: .userInitiated) {
                await upvote()
            }
        })
        
        // downvote
        let (downvoteText, downvoteImg) = hierarchicalComment.commentView.myVote == .downvote ?
        ("Undo downvote", "arrow.down.square.fill") :
        ("Downvote", "arrow.down.square")
        ret.append(MenuFunction(
            text: downvoteText,
            imageName: downvoteImg,
            destructiveActionPrompt: nil,
            enabled: true) {
            Task(priority: .userInitiated) {
                await downvote()
            }
        })
        
        // save
        let (saveText, saveImg) = hierarchicalComment.commentView.saved ? ("Unsave", "bookmark.slash") : ("Save", "bookmark")
        ret.append(MenuFunction(
            text: saveText,
            imageName: saveImg,
            destructiveActionPrompt: nil,
            enabled: true) {
            Task(priority: .userInitiated) {
                await saveComment()
            }
        })
        
        // reply
        if let replyCallback = replyToComment {
            ret.append(MenuFunction(
                text: "Reply",
                imageName: "arrowshape.turn.up.left",
                destructiveActionPrompt: nil,
                enabled: true) {
                    replyCallback(hierarchicalComment.commentView)
                })
        }
        
        // delete
        if hierarchicalComment.commentView.creator.id == appState.currentActiveAccount.id {
            ret.append(MenuFunction(
                text: "Delete",
                imageName: "trash",
                destructiveActionPrompt: "Are you sure you want to delete this comment?  This cannot be undone.",
                enabled: !hierarchicalComment.commentView.comment.deleted) {
                Task(priority: .userInitiated) {
                    await deleteComment()
                }
            })
        }
        
        // share
        if let url = URL(string: hierarchicalComment.commentView.comment.apId) {
            ret.append(MenuFunction(
                text: "Share",
                imageName: "square.and.arrow.up",
                destructiveActionPrompt: nil,
                enabled: true) {
                showShareSheet(URLtoShare: url)
            })
        }
        
        // report
        ret.append(MenuFunction(
            text: "Report",
            imageName: "exclamationmark.shield",
            destructiveActionPrompt: nil,
            enabled: true) {
                isComposingReport = true
            })
                   
        return ret
    }
    // swiftlint:enable function_body_length
}
