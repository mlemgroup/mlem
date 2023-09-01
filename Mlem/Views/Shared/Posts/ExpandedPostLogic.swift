//
//  ExpandedPostLogic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation

extension ExpandedPost {
    // MARK: Interaction callbacks
    
    func upvotePost() async {
        await postTracker.voteOnPost(post: post, inputOp: .upvote)
    }

    func downvotePost() async {
        await postTracker.voteOnPost(post: post, inputOp: .downvote)
    }
    
    func savePost() async {
        // TODO: Eric figure out how to propagate state fake into here
        await postTracker.toggleSave(post: post)
    }
    
    func replyToPost() {
        editorTracker.openEditor(with: ConcreteEditorModel(
            post: PostModel(from: post),
            commentTracker: commentTracker,
            operation: PostOperation.replyToPost
        ))
    }
    
    func reportPost() {
        editorTracker.openEditor(with: ConcreteEditorModel(
            post: PostModel(from: post),
            operation: PostOperation.reportPost
        ))
    }
    
    func replyToComment(comment: APICommentView) {
        editorTracker.openEditor(with: ConcreteEditorModel(
            comment: comment,
            commentTracker: commentTracker,
            operation: CommentOperation.replyToComment
        ))
    }
    
    func blockUser() async {
        do {
            let response = try await apiClient.blockPerson(id: post.creator.id, shouldBlock: true)
            if response.blocked {
                postTracker.removeUserPosts(from: post.creator.id)
                hapticManager.play(haptic: .violentSuccess, priority: .high)
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
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await upvotePost()
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
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await downvotePost()
            }
        })
        
        // save
        let (saveText, saveImg) = post.saved ? ("Unsave", "bookmark.slash") : ("Save", "bookmark")
        ret.append(MenuFunction(
            text: saveText,
            imageName: saveImg,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await savePost()
            }
        })
        
        // reply
        ret.append(MenuFunction(
            text: "Reply",
            imageName: "arrowshape.turn.up.left",
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            replyToPost()
        })
        
        if post.creator.id == appState.currentActiveAccount.id {
            // edit
            ret.append(MenuFunction(
                text: "Edit",
                imageName: "pencil",
                destructiveActionPrompt: nil,
                enabled: true
            ) {
                editorTracker.openEditor(with: PostEditorModel(
                    community: post.community,
                    postTracker: postTracker,
                    editPost: post.post,
                    responseCallback: updatePost
                ))
            })
            
            // delete
            ret.append(MenuFunction(
                text: "Delete",
                imageName: "trash",
                destructiveActionPrompt: "Are you sure you want to delete this post?  This cannot be undone.",
                enabled: !post.post.deleted
            ) {
                Task(priority: .userInitiated) {
                    await postTracker.delete(post: post)
                }
            })
        }
        
        // share
        ret.append(MenuFunction(
            text: "Share",
            imageName: "square.and.arrow.up",
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            if let url = URL(string: post.post.apId) {
                showShareSheet(URLtoShare: url)
            }
        })
        
        // report
        ret.append(MenuFunction(
            text: "Report Post",
            imageName: AppConstants.reportSymbolName,
            destructiveActionPrompt: AppConstants.reportPostPrompt,
            enabled: true
        ) {
            reportPost()
        })
        
        // block user
        ret.append(MenuFunction(
            text: "Block User",
            imageName: AppConstants.blockUserSymbolName,
            destructiveActionPrompt: AppConstants.blockUserPrompt,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await blockUser()
            }
        })
        
        return ret
    }

    // swiftlint:enable function_body_length

    @discardableResult
    func loadComments() async -> Bool {
        defer { isLoading = false }
        isLoading = true
        
        do {
            let comments = try await commentRepository.comments(for: post.post.id)
            let sorted = sortComments(comments, by: commentSortingType)
            commentTracker.comments = sorted
            return true
        } catch {
            commentErrorDetails = ErrorDetails(error: error, refresh: loadComments)
            return false
        }
    }
    
    /**
     Refreshes the comment feed. Does not touch the isLoading bool, since that status cue is handled implicitly by .refreshable
     */
    func refreshComments() async {
        do {
            let comments = try await commentRepository.comments(for: post.post.id)
            commentTracker.comments = sortComments(comments, by: commentSortingType)
        } catch {
            errorHandler.handle(.init(
                title: "Failed to refresh",
                message: "Please try again",
                underlyingError: error
            )
            )
        }
    }

    func sortComments(_ comments: [HierarchicalComment], by sort: CommentSortType) -> [HierarchicalComment] {
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
    
    func updatePost(newPost: PostModel) {
        post = newPost
    }
}
