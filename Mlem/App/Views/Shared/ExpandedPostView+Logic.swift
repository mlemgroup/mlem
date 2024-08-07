//
//  ExpandedPostView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 12/07/2024.
//

import MlemMiddleware
import SwiftUI

extension ExpandedPostView {
    func resolveComments(post: any Post) {
        Task {
            commentResolveLoading = true
            loadingState = .idle
            await loadComments(post: post)
            commentResolveLoading = false
        }
    }
    
    func loadComments(post: any Post) async {
        guard loadingState == .idle else { return }
        loadingState = .loading
        do {
            let newComments = try await post.getComments(sort: .top, page: 1, maxDepth: 8, limit: 50)
            if let first = comments.first, first.api != appState.firstApi {
                resolveCommentTree(comments: newComments)
            } else {
                builtCommentTree(comments: newComments)
            }
            loadingState = .done
        } catch {
            handleError(error)
        }
    }
    
    func builtCommentTree(comments newComments: [Comment2]) {
        var output: [CommentWrapper] = []
        var commentsKeyedById: [Int: CommentWrapper] = [:]
        var commentsKeyedByActorId: [URL: CommentWrapper] = [:]
        
        for comment in newComments {
            let wrapper: CommentWrapper = .init(comment)
            commentsKeyedById[comment.id] = wrapper
            commentsKeyedByActorId[comment.actorId] = wrapper
            if let parentId = comment.parentCommentIds.last {
                commentsKeyedById[parentId]?.addChild(wrapper)
            } else {
                output.append(wrapper)
            }
        }
        comments = output
        self.commentsKeyedByActorId = commentsKeyedByActorId
    }
    
    func resolveCommentTree(comments newComments: [Comment2]) {
        var commentsKeyedById: [Int: CommentWrapper] = [:]
        
        for comment in newComments {
            if let existing = commentsKeyedByActorId[comment.actorId] {
                existing.comment2 = comment
                commentsKeyedById[comment.id] = existing
            } else {
                let wrapper: CommentWrapper = .init(comment)
                commentsKeyedById[comment.id] = wrapper
                commentsKeyedByActorId[comment.actorId] = wrapper
                if let parentId = comment.parentCommentIds.last {
                    if let parent = commentsKeyedById[parentId] {
                        parent.addChild(wrapper)
                    } else {
                        assertionFailure("This should never happen because the API returns comments in order of depth asc.")
                    }
                } else {
                    comments.append(wrapper)
                }
            }
        }
    }
}
