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
            case let .comment(comment, parentCount): max(0, comment.depth - parentCount)
            }
        }
    }
    
    private(set) var nodes: [CommentTreeNode] = []
    private(set) var nodesKeyedByActorId: [ActorIdentifier: CommentTreeNode] = [:]
    
    var loadingState: LoadingState = .idle
    var errorDetails: ErrorDetails?
    
    var root: Root
    
    var sort: CommentSortType = .init(LegacySettings.main.commentSort)
    
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
    
    @MainActor
    func load(ensuringPresenceOf ensuredComment: (any CommentStubProviding)? = nil) async {
        guard loadingState == .idle else { return }
        loadingState = .loading
        do {
            var newComments = try await fetchComments(page: 1)
            if let ensuredComment {
                let comment: any Comment
                let api = root.wrappedValue.api
                if let ensuredComment = ensuredComment as? any Comment, ensuredComment.api == api {
                    comment = ensuredComment
                } else if let ensuredComment = ensuredComment as? CommentStub {
                    print("CommentTreeTracker: Resolving comment...")
                    comment = try await api.getComment(url: ensuredComment.resolvableUrl)
                } else {
                    assertionFailure()
                    return
                }
                if !nodesKeyedByActorId.keys.contains(comment.actorId) {
                    // Find the first parent of the ensured comment that isn't in `newComments`.
                    // This will be the starting point for the second page of comments to load.
                    let idsToSearch = comment.parentCommentIds + [comment.id]
                    let firstAbsentParentId = idsToSearch.first(
                        where: { id in !newComments.contains(where: { $0.id == id }) }
                    )
                    if let firstAbsentParentId {
                        let extraComments = try await api.getComments(
                            parentId: firstAbsentParentId,
                            sort: sort,
                            page: 1,
                            maxDepth: 8,
                            limit: 999
                        )
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
    private func fetchComments(page: Int) async throws -> [Comment2] {
        switch root {
        case let .post(post):
            return try await post.getComments(
                sort: sort,
                page: page,
                maxDepth: LegacySettings.main.maxCommentDepth,
                limit: 50
            )
        case let .comment(comment, parentCount):
            return try await comment.getChildren(
                sort: sort,
                includedParentCount: parentCount,
                page: page,
                maxDepth: min(8, LegacySettings.main.maxCommentDepth) + parentCount,
                limit: 999
            )
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
    
    func insertCreatedComment(_ comment: Comment2, parent: (any Comment1Providing)? = nil) {
        let wrapper = CommentTreeNode(comment)
        if let parent {
            assert(!comment.parentCommentIds.isEmpty)
            nodesKeyedByActorId[parent.actorId]?.addChild(wrapper)
        } else {
            assert(comment.parentCommentIds.isEmpty)
            nodes.prepend(wrapper)
        }
    }
    
    @MainActor
    func insertAdditionalComments(comments newComments: [Comment2]) async {
        await buildCommentTree(comments: newComments, clear: false)
    }
    
    @MainActor
    private func buildCommentTree(comments newComments: [Comment2], clear: Bool = true) async {
        var output: [CommentTreeNode] = clear ? [] : nodes
        var commentsKeyedById: [Int: CommentTreeNode] = [:]
        var commentsKeyedByActorId: [ActorIdentifier: CommentTreeNode] = clear ? [:] : nodesKeyedByActorId
        
        // From 0.19.0 onwards, a comment's parent is guaranteed to precede it in the array.
        //
        // In 0.18.x versions, this isn't always the case - sometimes the parent can come after
        // the child. As the tree-building logic relies on correct comment order, we need to sort
        // the comments by depth before processing them.
        //
        // Also on 0.18.x, in super large comment threads where some comments are hidden under
        // "More replies", comments may be included that don't have a parent *anywhere* in the
        // list! There's nothing we can do in that circumstance, so those comments are ignored
        // entirely. I'm not sure under what circumstances this happens. Going to the parent comment
        // on lemmy-ui loads the comment just fine, but neither the "Show context" nor "Show replies"
        // buttons work. This issue could be related to Lemmy 0.18, or maybe Beehaw's database is
        // broken somehow. Comment example: https://beehaw.org/comment/4033679
        
        var sortedComments: [Comment2]
        if let version = try? await newComments.first?.api.version, version < .v0_19_0 {
            sortedComments = newComments.sorted { $0.depth < $1.depth }
        } else {
            sortedComments = newComments
        }
        
        for comment in sortedComments {
            if commentsKeyedByActorId.keys.contains(comment.actorId) {
                commentsKeyedById[comment.id] = commentsKeyedByActorId[comment.actorId]
                continue
            }
            let wrapper: CommentTreeNode = .init(comment)
            commentsKeyedById[comment.id] = wrapper
            commentsKeyedByActorId[comment.actorId] = wrapper
            if let parentId = comment.parentCommentIds.last, comment.depth > root.depth {
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
    
    private func resolveCommentTree(comments newComments: [Comment2]) {
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
