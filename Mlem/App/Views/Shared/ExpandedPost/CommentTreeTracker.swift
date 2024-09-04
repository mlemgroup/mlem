//
//  ExpandedPostView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 12/07/2024.
//

import MlemMiddleware
import SwiftUI

@Observable
class CommentTreeTracker: Hashable {
    enum Root {
        case post(any Post)
        case comment(any Comment, parentCount: Int)
        
        var wrappedValue: any Interactable1Providing & ActorIdentifiable {
            switch self {
            case let .post(post): post
            case let .comment(comment, _): comment
            }
        }
        
        var depth: Int {
            switch self {
            case .post: -1
            case let .comment(comment, _): comment.depth
            }
        }
    }
    
    private(set) var comments: [CommentWrapper] = []
    private(set) var commentsKeyedByActorId: [URL: CommentWrapper] = [:]
    
    var loadingState: LoadingState = .idle
    
    var root: Root
    
    var sort: ApiCommentSortType = Settings.main.commentSort
    
    init(root: Root) {
        self.root = root
    }
    
    private var appState: AppState { .main }
    
    func load(ensuringPresenceOf ensuredComment: (any CommentStubProviding)? = nil) async {
        guard loadingState == .idle else { return }
        loadingState = .loading
        do {
            var newComments: [Comment2]
            switch root {
            case let .post(post):
                newComments = try await post.getComments(sort: sort, page: 1, maxDepth: 8, limit: 50)
            case let .comment(comment, parentCount):
                newComments = try await comment.getChildren(
                    sort: sort,
                    includedParentCount: parentCount,
                    page: 1,
                    maxDepth: 8,
                    limit: 50
                )
            }
            if let ensuredComment, !commentsKeyedByActorId.keys.contains(ensuredComment.actorId) {
                let comment: any Comment
                let api = root.wrappedValue.api
                if let ensuredComment = ensuredComment as? any Comment, ensuredComment.api == api {
                    comment = ensuredComment
                } else {
                    print("CommentTreeTracker: Resolving comment...")
                    comment = try await api.getComment(actorId: ensuredComment.actorId)
                }
                let idsToSearch = comment.parentCommentIds + [comment.id]
                if let parentId = idsToSearch.first(where: { id in !newComments.contains(where: { $0.id == id }) }) {
                    let extraComments = try await api.getComments(
                        parentId: parentId,
                        sort: sort,
                        page: 1,
                        maxDepth: 8,
                        limit: 50
                    )
                    newComments.append(contentsOf: extraComments)
                }
            }
            if let first = comments.first, first.api != root.wrappedValue.api {
                resolveCommentTree(comments: newComments)
            } else {
                buildCommentTree(comments: newComments)
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
        let wrapper = CommentWrapper(comment)
        if let parent {
            assert(!comment.parentCommentIds.isEmpty)
            commentsKeyedByActorId[parent.actorId]?.addChild(wrapper)
        } else {
            assert(comment.parentCommentIds.isEmpty)
            comments.prepend(wrapper)
        }
    }
    
    private func buildCommentTree(comments newComments: [Comment2]) {
        var output: [CommentWrapper] = []
        var commentsKeyedById: [Int: CommentWrapper] = [:]
        var commentsKeyedByActorId: [URL: CommentWrapper] = [:]
        
        for comment in newComments {
            let wrapper: CommentWrapper = .init(comment)
            commentsKeyedById[comment.id] = wrapper
            commentsKeyedByActorId[comment.actorId] = wrapper
            if let parentId = comment.parentCommentIds.last, comment.parentCommentIds.count > root.depth {
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
    
    static func == (lhs: CommentTreeTracker, rhs: CommentTreeTracker) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
