//
//  ExpandedPostLogic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation

extension ExpandedPost {
    // MARK: Interaction callbacks
    
    func replyToPost() {
        editorTracker.openEditor(with: ConcreteEditorModel(
            post: post,
            commentTracker: commentTracker,
            operation: PostOperation.replyToPost
        ))
    }
    
    func replyToComment(comment: APICommentView) {
        editorTracker.openEditor(with: ConcreteEditorModel(
            comment: comment,
            commentTracker: commentTracker,
            operation: CommentOperation.replyToComment
        ))
    }
    
    // MARK: Helper functions

    @discardableResult
    func loadComments() async -> Bool {
        defer { isLoading = false }
        isLoading = true
        
        do {
            // Making this request should mark unread comments as read, but doesn't appear to so we do it manually
            let newPost = try await PostModel(from: postRepository.loadPost(postId: post.postId))
            newPost.unreadCommentCount = 0
            post.reinit(from: newPost)
            
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
}
