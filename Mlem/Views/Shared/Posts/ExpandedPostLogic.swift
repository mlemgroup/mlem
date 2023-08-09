//
//  ExpandedPostLogic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation

extension ExpandedPost {
    
    // MARK: Interaction callbacks
    
    // TODO: add flag
    func markPostAsRead() async {
        do {
            post = try await postRepository.markRead(for: post.post.id, read: true)
            postTracker.update(with: post)
        } catch {
            errorHandler.handle(.init(underlyingError: error))
        }
    }
    
    func upvotePost() async {
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
            await voteOnPost(inputOp: .upvote)

            // unfake downvote
            dirty = false
            return
        }
    }

    func downvotePost() async {
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
            await voteOnPost(inputOp: .downvote)

            // unfake upvote
            dirty = false
            return
        }
    }
    
    /// Votes on a post
    /// - Parameter inputOp: The voting operation to perform
    func voteOnPost(inputOp: ScoringOperation) async {
        do {
            hapticManager.play(haptic: .gentleSuccess)
            let operation = post.myVote == inputOp ? ScoringOperation.resetVote : inputOp
            self.post = try await ratePost(
                postId: post.post.id,
                operation: operation,
                account: appState.currentActiveAccount,
                postTracker: postTracker,
                appState: appState
            )
        } catch {
            hapticManager.play(haptic: .failure)
            appState.contextualError = .init(underlyingError: error)
        }
    }
    
    /**
     Sends a save request for the current post
     */
    func savePost() async {
        guard dirty else {
            // fake save
            dirtySaved.toggle()
            dirty = true
            hapticManager.play(haptic: .success)
            
            do {
                self.post = try await sendSavePostRequest(
                    account: appState.currentActiveAccount,
                    postId: post.post.id,
                    save: dirtySaved,
                    postTracker: postTracker
                )
            } catch {
                appState.contextualError = .init(underlyingError: error)
            }
            dirty = false
            return
        }
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
        editorTracker.openEditor(with: ConcreteEditorModel(appState: appState,
                                                           post: post,
                                                           commentTracker: commentTracker,
                                                           operation: PostOperation.replyToPost))
    }
    
    func reportPost() {
        editorTracker.openEditor(with: ConcreteEditorModel(appState: appState,
                                                           post: post,
                                                           operation: PostOperation.reportPost))
    }
    
    func replyToComment(comment: APICommentView) {
        editorTracker.openEditor(with: ConcreteEditorModel(appState: appState,
                                                           comment: comment,
                                                           commentTracker: commentTracker,
                                                           operation: CommentOperation.replyToComment))
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
                await notifier.add(.success("Blocked \(post.creator.name)"))
            }
        } catch {
            errorHandler.handle(
                .init(
                    message: "Unable to block \(post.creator.name)",
                    style: .toast,
                    underlyingError: error
                )
            )
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
                await savePost()
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
        
        if post.creator.id == appState.currentActiveAccount.id {
            // edit
            ret.append(MenuFunction(
                text: "Edit",
                imageName: "pencil",
                destructiveActionPrompt: nil,
                enabled: true) {
                    editorTracker.openEditor(with: PostEditorModel(community: post.community,
                                                                   appState: appState,
                                                                   postTracker: postTracker,
                                                                   editPost: post.post,
                                                                   responseCallback: updatePost))
                })
            
            // delete
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
        defer { isLoading = false }
        isLoading = true
        
        do {
            let comments = try await commentRepository.comments(for: post.post.id)
            let sorted = sortComments(comments, by: defaultCommentSorting)
            commentTracker.comments = sorted
        } catch {
            errorHandler.handle(
                .init(
                    title: "Failed to load comments",
                    message: "Please refresh to try again",
                    underlyingError: error
                )
            )
        }
    }
    
    /**
     Refreshes the comment feed. Does not touch the isLoading bool, since that status cue is handled implicitly by .refreshable
     */
    func refreshComments() async {
        do {
            let comments = try await commentRepository.comments(for: post.post.id)
            commentTracker.comments = sortComments(comments, by: defaultCommentSorting)
        } catch {
            errorHandler.handle(.init(title: "Failed to refresh",
                                      message: "Please try again",
                                      underlyingError: error))
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
    
    func updatePost(newPost: APIPostView) {
        post = newPost
    }
}
