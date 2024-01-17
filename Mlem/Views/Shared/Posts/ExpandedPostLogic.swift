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
        // ensure post tracker isn't loading--avoids state faking causing flickering when post tracker doesn't upvote
        guard !postTracker.isLoading else { return }
        
        // fake state
        let oldPost = post // save this to pass to postTracker
        let operation = post.votes.myVote == .upvote ? ScoringOperation.resetVote : .upvote
        post = PostModel(from: post, votes: post.votes.applyScoringOperation(operation: operation))
        
        // perform upvote--passing in oldPost so that the state-faked upvote of post doesn't result in the opposite vote being passed in
        post = await postTracker.voteOnPost(post: oldPost, inputOp: .upvote)
    }

    func downvotePost() async {
        // fake state
        let oldPost = post
        let operation = post.votes.myVote == .downvote ? ScoringOperation.resetVote : .downvote
        post = PostModel(from: post, votes: post.votes.applyScoringOperation(operation: operation))
        
        // perform downvote
        post = await postTracker.voteOnPost(post: oldPost, inputOp: .downvote)
    }
    
    func savePost() async {
        // fake state
        var stateFakedPost = PostModel(from: post, saved: !post.saved)
        if upvoteOnSave, !post.saved, stateFakedPost.votes.myVote != .upvote {
            stateFakedPost.votes = stateFakedPost.votes.applyScoringOperation(operation: .upvote)
        }
        let oldPost = post
        post = stateFakedPost
        
        // perform save
        post = await postTracker.toggleSave(post: oldPost)
    }
    
    func replyToPost() {
        editorTracker.openEditor(with: ConcreteEditorModel(
            post: post,
            commentTracker: commentTracker,
            operation: PostOperation.replyToPost
        ))
    }
    
    func reportPost() {
        editorTracker.openEditor(with: ConcreteEditorModel(
            post: post,
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
            let response = try await apiClient.blockPerson(id: post.creator.userId, shouldBlock: true)
            if response.blocked {
                postTracker.removeUserPosts(from: post.creator.userId)
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
        let (upvoteText, upvoteImg) = post.votes.myVote == .upvote ?
            ("Undo Upvote", Icons.upvoteSquareFill) :
            ("Upvote", Icons.upvoteSquare)
        ret.append(MenuFunction.standardMenuFunction(
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
        let (downvoteText, downvoteImg) = post.votes.myVote == .downvote ?
            ("Undo Downvote", Icons.downvoteSquareFill) :
            ("Downvote", Icons.downvoteSquare)
        ret.append(MenuFunction.standardMenuFunction(
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
        let (saveText, saveImg) = post.saved ?
            ("Unsave", Icons.unsave) :
            ("Save", Icons.save)
        ret.append(MenuFunction.standardMenuFunction(
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
        ret.append(MenuFunction.standardMenuFunction(
            text: "Reply",
            imageName: Icons.reply,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            replyToPost()
        })
        
        if appState.isCurrentAccountId(post.creator.userId) {
            // edit
            ret.append(MenuFunction.standardMenuFunction(
                text: "Edit",
                imageName: Icons.edit,
                destructiveActionPrompt: nil,
                enabled: true
            ) {
                editorTracker.openEditor(with: PostEditorModel(
                    post: post,
                    postTracker: postTracker,
                    responseCallback: updatePost
                ))
            })
            
            // delete
            ret.append(MenuFunction.standardMenuFunction(
                text: "Delete",
                imageName: Icons.delete,
                destructiveActionPrompt: "Are you sure you want to delete this post?  This cannot be undone.",
                enabled: !post.post.deleted
            ) {
                Task(priority: .userInitiated) {
                    await postTracker.delete(post: post)
                }
            })
        }
        
        // share
        if let url = URL(string: post.post.apId) {
            ret.append(MenuFunction.shareMenuFunction(url: url))
        }
        
        // report
        ret.append(MenuFunction.standardMenuFunction(
            text: "Report Post",
            imageName: Icons.moderationReport,
            destructiveActionPrompt: AppConstants.reportPostPrompt,
            enabled: true
        ) {
            reportPost()
        })
        
        // block user
        ret.append(MenuFunction.standardMenuFunction(
            text: "Block User",
            imageName: Icons.userBlock,
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
            // Making this request marks unread comments as read.
            post = try await PostModel(from: postRepository.loadPost(postId: post.postId))
            postTracker.update(with: post)
            
            let comments = try await commentRepository.comments(for: post.post.id)
            let sorted = sortComments(comments, by: commentSortingType)
            commentTracker.comments = sorted
            return true
        } catch {
            commentErrorDetails = ErrorDetails(error: error, refresh: loadComments)
            return false
        }
    }
    
    /// Refreshes the comment feed. Does not touch the isLoading bool, since that status cue is handled implicitly by .refreshable
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
