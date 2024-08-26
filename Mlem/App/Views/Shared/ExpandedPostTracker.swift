//
//  ExpandedPostView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 12/07/2024.
//

import MlemMiddleware
import SwiftUI

@Observable
class ExpandedPostTracker: Hashable {
    private(set) var comments: [CommentWrapper] = []
    private(set) var commentsKeyedByActorId: [URL: CommentWrapper] = [:]
    
    var loadingState: LoadingState = .idle
    
    var post: any Post
    
    var sort: ApiCommentSortType = Settings.main.commentSort
    
    init(post: any Post) {
        self.post = post
    }
    
    private var appState: AppState { .main }
    
    func load() async {
        guard loadingState == .idle else { return }
        loadingState = .loading
        do {
            let newComments = try await post.getComments(sort: sort, page: 1, maxDepth: 8, limit: 50)
            if let first = comments.first, first.api != post.api {
                resolveCommentTree(comments: newComments)
            } else {
                builtCommentTree(comments: newComments)
            }
            loadingState = .done
        } catch {
            handleError(error)
        }
    }
    
    func clear() {
        comments.removeAll()
        commentsKeyedByActorId.removeAll()
        loadingState = .idle
    }
    
    func insertCreatedComment(_ comment: Comment2, parent: (any Comment1Providing)? = nil) {
        if let actorId = parent?.actorId {
            print(commentsKeyedByActorId.keys.contains(actorId))
        }
        let wrapper = CommentWrapper(comment)
        if let parent {
            assert(!comment.parentCommentIds.isEmpty)
            commentsKeyedByActorId[parent.actorId]?.addChild(wrapper)
        } else {
            assert(comment.parentCommentIds.isEmpty)
            comments.prepend(wrapper)
        }
    }
    
    private func builtCommentTree(comments newComments: [Comment2]) {
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
    
    private func resolveCommentTree(comments newComments: [Comment2]) {
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
    
    static func == (lhs: ExpandedPostTracker, rhs: ExpandedPostTracker) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
