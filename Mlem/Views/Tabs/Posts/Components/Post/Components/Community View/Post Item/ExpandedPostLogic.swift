//
//  ExpandedPostLogic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation

extension ExpandedPost {
    
    // MARK: Interaction callbacks
    
    /// Votes on a post
    /// - Parameter inputOp: The voting operation to perform
    func voteOnPost(inputOp: ScoringOperation) async {
        do {
            let operation = post.myVote == inputOp ? ScoringOperation.resetVote : inputOp
            self.post = try await ratePost(
                postId: post.post.id,
                operation: operation,
                account: appState.currentActiveAccount,
                postTracker: postTracker,
                appState: appState
            )
        } catch {
            appState.contextualError = .init(underlyingError: error)
        }
    }
    
    /**
     Sends a save request for the current post
     */
    func savePost(_ save: Bool) async throws {
        self.post = try await sendSavePostRequest(
            account: appState.currentActiveAccount,
            postId: post.post.id,
            save: save,
            postTracker: postTracker
        )
    }
    
    func deletePost() async {
        do {
            // TODO: renamed this function and/or move `deleteComment` out of the global scope to avoid
            // having to refer to our own module
            _ = try await Mlem.deletePost(
                postId: post.post.id,
                account: appState.currentActiveAccount,
                postTracker: postTracker,
                appState: appState
            )
        } catch {
            appState.contextualError = .init(underlyingError: error)
        }
    }
    
    func replyToPost() {
        isPostingComment = true
    }
    
    func replyToComment(replyTo: APICommentView) {
        commentReplyingTo = replyTo
        isReplyingToComment = true
    }
    
    // MARK: Helper functions
    
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
                isPostingComment = true
            })
        
        // delete
        if post.creator.id == appState.currentActiveAccount.id {
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

    func loadComments() async {
        defer { commentTracker.isLoading = false }

        commentTracker.isLoading = true
        do {
            let request = GetCommentsRequest(account: appState.currentActiveAccount, postId: post.post.id)
            let response = try await APIClient().perform(request: request)
            commentTracker.comments = sortComments(response.comments.hierarchicalRepresentation, by: defaultCommentSorting)
        } catch {
            appState.contextualError = .init(
                title: "Failed to load comments",
                message: "Please refresh to try again",
                underlyingError: error
            )
        }
    }

    internal func sortComments(_ comments: [HierarchicalComment], by sort: CommentSortType) -> [HierarchicalComment] {
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
}
