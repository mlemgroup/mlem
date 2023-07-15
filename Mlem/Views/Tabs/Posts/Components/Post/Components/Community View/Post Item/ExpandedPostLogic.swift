//
//  ExpandedPostLogic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import AlertToast

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
        responseItem = ConcreteRespondable(appState: appState, post: post, commentTracker: commentTracker)
    }
    
    func reportPost() {
        responseItem = ConcreteRespondable(appState: appState, post: post, report: true)
    }
    
    func replyToComment(comment: APICommentView) {
        responseItem = ConcreteRespondable(appState: appState, comment: comment, commentTracker: commentTracker)
    }
    
    func blockUser() async {
        do {
            let blocked = try await blockPerson(
                account: appState.currentActiveAccount,
                person: post.creator,
                blocked: true
            )
            if blocked {
                postTracker.removePosts(from: post.creator.id)

                let toast = AlertToast(
                    displayMode: .alert,
                    type: .complete(.blue),
                    title: "Blocked \(post.creator.name)"
                )
                appState.toast = toast
                appState.isShowingToast = true
            } // Show Toast
        } catch {
            let toast = AlertToast(
                displayMode: .alert,
                type: .error(.red),
                title: "Unable to block \(post.creator.name)"
            )
            appState.toast = toast
            appState.isShowingToast = true
        }
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
                replyToPost()
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
        
        // report
        ret.append(MenuFunction(text: "Report Post",
                                imageName: AppConstants.reportSymbolName,
                                destructiveActionPrompt: nil,
                                enabled: true) {
            reportPost()
        })
        
        // block user
        ret.append(MenuFunction(
            text: "Block User",
            imageName: AppConstants.blockUserSymbolName,
            destructiveActionPrompt: nil,
            enabled: true) {
                Task(priority: .userInitiated) {
                    await blockUser()
                }
            })
        
        return ret
    }
    // swiftlint:enable function_body_length

    func loadComments() async {
        defer { commentTracker.isLoading = false }

        commentTracker.isLoading = true
            let comments = await commentRepository.comments(for: post.post.id)
            commentTracker.comments = sortComments(comments, by: defaultCommentSorting)
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
