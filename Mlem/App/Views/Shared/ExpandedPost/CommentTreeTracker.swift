//
//  ExpandedPostView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 12/07/2024.
//

import MlemMiddleware
import os
import SwiftUI

@Observable
class CommentTreeTracker: Hashable {
    private let log: Logger = .mlemLogger()
    
    enum Root {
        case post(Post)
        case comment(Comment, parentCount: Int)
        
        var wrappedValue: any InteractableProviding & ActorIdentifiable {
            switch self {
            case let .post(post): post
            case let .comment(comment, _): comment
            }
        }
        
        var depth: Int {
            switch self {
            case .post: -1
            case let .comment(comment, parentCount): max(0, comment.depth - parentCount)
            }
        }
    }
    
    private(set) var nodes: [CommentTreeNode] = []
    private(set) var nodesKeyedByActorId: [ActorIdentifier: CommentTreeNode] = [:]
    
    var loadingState: LoadingState = .idle
    var errorDetails: ErrorDetails?
    
    var root: Root
    
    var sort: CommentSortType = .init(Settings.get(\.comment_defaultSort))
    
    init(root: Root) {
        self.root = root
    }
    
    var proposedDepthOffset: Int {
        switch root {
        case .comment:
            if let first = nodes.first, first.comment.depth > 0 {
                return first.comment.depth - 1
            }
            return 0
        default: return 0
        }
    }
    
    private var appState: AppState { .main }

    func getNode(actorId: ActorIdentifier) -> CommentTreeNode? {
        nodesKeyedByActorId[actorId]
    }

    func hasNode(actorId: ActorIdentifier) -> Bool {
        return nodesKeyedByActorId.keys.contains(actorId)
    }
    
    @MainActor
    func load(ensuringPresenceOf ensuredComment: (any CommentResolvable)? = nil) async {
        guard loadingState == .idle else { return }
        loadingState = .loading
        do {
            var newComments = try await fetchComments()

            if let ensuredComment {
                let comment = try await ensuredComment.asComment()
                let api = root.wrappedValue.api
                if !nodesKeyedByActorId.keys.contains(comment.actorId) {
                    // Find the first parent of the ensured comment that isn't in `newComments`.
                    // This will be the starting point for the second page of comments to load.
                    let idsToSearch = comment.parentCommentIds + [comment.id]
                    let firstAbsentParentId = idsToSearch.last(
                        where: { id in !newComments.contains(where: { $0.id == id }) }
                    )
                    if let firstAbsentParentId {
                        let extraComments = try await api.getComments(
                            parentId: firstAbsentParentId,
                            pageInfo: .init(cursor: .first, limit: 999),
                            sort: sort,
                            maxDepth: 8
                        ).items
                        newComments.append(contentsOf: extraComments)
                    }
                }
            }
            if let first = newComments.first, first.api != root.wrappedValue.api {
                resolveCommentTree(comments: newComments)
            } else {
                await buildCommentTree(comments: newComments)
            }
            loadingState = .done
            errorDetails = nil
        } catch {
            handleFailure(error)
        }
    }
    
    @MainActor
    private func fetchComments() async throws -> [Comment] {
        switch root {
        case let .post(post):
            return try await post.getComments(
                sort: sort,
                pageInfo: .init(cursor: .first, limit: 50),
                maxDepth: Settings.get(\.comment_maxDepth)
            ).items
        case let .comment(comment, parentCount):
            return try await comment.getChildren(
                sort: sort,
                includedParentCount: parentCount,
                pageInfo: .init(cursor: .first, limit: 999),
                maxDepth: min(8, Settings.get(\.comment_maxDepth)) + parentCount
            ).items
        }
    }
    
    private func handleFailure(_ error: Error) {
        var details = handleErrorWithDetails(error)
        details?.refresh = {
            await self.load()
            return self.loadingState == .done
        }
        errorDetails = details
        loadingState = .idle
    }
    
    @MainActor
    func refresh() async {
        errorDetails = nil
        loadingState = .idle
        await load()
    }
    
    func clear() {
        nodes.removeAll()
        nodesKeyedByActorId.removeAll()
        loadingState = .idle
    }
    
    func insertCreatedComment(_ comment: Comment, parent: Comment? = nil) {
        let wrapper = CommentTreeNode(comment)
        nodesKeyedByActorId[comment.actorId] = wrapper
        if let parent {
            assert(!comment.parentCommentIds.isEmpty)
            nodesKeyedByActorId[parent.actorId]?.addChild(wrapper)
        } else {
            assert(comment.parentCommentIds.isEmpty)
            nodes.prepend(wrapper)
        }
    }
    
    @MainActor
    func insertAdditionalComments(comments newComments: [Comment]) async {
        await buildCommentTree(comments: newComments, clear: false)
    }
    
    func getThread(preceding target: Comment, limit: Int) -> [Comment] {
        var cur = nodesKeyedByActorId[target.actorId]
        var ret: [Comment] = .init()
        while ret.count < limit, let curNode = cur {
            ret.prepend(curNode.comment)
            cur = curNode.parent
        }
        
        assert(ret.count > 0, "Could not build thread from \(target.actorId)")
        return ret
    }
    
    @MainActor
    private func buildCommentTree(comments newComments: [Comment], clear: Bool = true) async {
        var output: [CommentTreeNode] = clear ? [] : nodes
        var commentsKeyedById: [Int: CommentTreeNode] = [:]
        var commentsKeyedByActorId: [ActorIdentifier: CommentTreeNode] = clear ? [:] : nodesKeyedByActorId

        let sortedComments = newComments.sorted { $0.depth < $1.depth }
        let firstDepth = sortedComments.first?.depth ?? 0
        
        for comment in sortedComments {
            if commentsKeyedByActorId.keys.contains(comment.actorId) {
                commentsKeyedById[comment.id] = commentsKeyedByActorId[comment.actorId]
                continue
            }
            let wrapper: CommentTreeNode = .init(comment)
            commentsKeyedById[comment.id] = wrapper
            commentsKeyedByActorId[comment.actorId] = wrapper
            if let parentId = comment.parentCommentIds.last, comment.depth > firstDepth {
                if let parent = commentsKeyedById[parentId] {
                    parent.addChild(wrapper)
                }
            } else {
                output.append(wrapper)
            }
        }
        nodes = output
        nodesKeyedByActorId = commentsKeyedByActorId
    }

    private func resolveCommentTree(comments newComments: [Comment]) {
        var commentsKeyedById: [Int: CommentTreeNode] = [:]
        
        for comment in newComments {
            if let existing = nodesKeyedByActorId[comment.actorId] {
                existing.comment = comment
                commentsKeyedById[comment.id] = existing
            } else {
                let wrapper: CommentTreeNode = .init(comment)
                commentsKeyedById[comment.id] = wrapper
                nodesKeyedByActorId[comment.actorId] = wrapper
                if let parentId = comment.parentCommentIds.last {
                    if let parent = commentsKeyedById[parentId] {
                        parent.addChild(wrapper)
                    } else {
                        assertionFailure("This should never happen because the API returns comments in order of depth asc.")
                    }
                } else {
                    nodes.append(wrapper)
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
