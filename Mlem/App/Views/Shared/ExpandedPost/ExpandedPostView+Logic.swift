//
//  ExpandedPostView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 24/08/2024.
//

import MlemMiddleware
import SwiftUI

extension ExpandedPostView {
    struct AnchorsKey: PreferenceKey {
        // swiftlint:disable:next nesting
        typealias Value = [ActorIdentifier?: Anchor<CGPoint>]

        static var defaultValue: Value { [:] }

        static func reduce(value: inout Value, nextValue: () -> Value) {
            value.merge(nextValue()) { $1 }
        }
    }
    
    enum PreviousVisitRecord {
        case firstVisit
        case revisit(topVisibleCommentAtLastVisit: ActorIdentifier)
        
        var isRevisit: Bool {
            switch self {
            case .revisit: true
            default: false
            }
        }
        
        var commentActorId: ActorIdentifier? {
            switch self {
            case let .revisit(topVisibleCommentAtLastVisit: value): value
            default: nil
            }
        }
    }

    enum CommentTreeViewType: Hashable {
        case comment(CommentTreeNode)
        case unloadedComments(comment: CommentTreeNode, count: Int)
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case let .comment(comment):
                hasher.combine(1)
                hasher.combine(comment.actorId)
            case let .unloadedComments(comment, _):
                hasher.combine(2)
                hasher.combine(comment.actorId)
            }
        }
    }
    
    var hasNoComments: Bool {
        if tracker?.loadingState == .done {
            return tracker?.nodesKeyedByActorId.count == 0
        }
        return (post.commentCount.value ?? -1) == 0
    }
    
    var showLoadingSymbol: Bool {
        // Don't need to show ProgressView if there's nothing to scroll to
        if scrollTargetedComment == nil { return false }
        return !scrolledToScrollTargetedComment
    }
    
    func showScrollToLastVisitButton(post: UnifiedPostModel) -> Bool {
        guard (post.commentCount.value_ ?? 0) > 10 else { return false }
        var commentId = previousVisitRecord?.commentActorId
        if topVisibleItem.isAtPost, commentId == nil {
            commentId = topVisibleItem.furthestVisitedComment
        }
        guard let commentId, let tracker else { return false }
        let nodes = tracker.nodes.reduce([]) { $0 + $1.tree(hideIfCollapsed: false) }
        let index = nodes.firstIndex { $0.actorId == commentId }
        guard let index else { return false }
        return index > 1
    }
    
    func togglePostCollapsed(post: UnifiedPostModel, scrollProxy: ScrollViewProxy) {
        withAnimation(UIAccessibility.isReduceMotionEnabled ? nil : .default) {
            postCollapsed.toggle()
            if postCollapsed {
                scrollProxy.scrollTo(post.actorId)
            }
        }
    }
    
    func generateViewTree(for nodes: [CommentTreeNode]) -> [CommentTreeViewType] {
        nodes.reduce([]) { $0 + generateViewTree(for: $1) }
    }
    
    func generateViewTree(for node: CommentTreeNode) -> [CommentTreeViewType] {
        let comment = node.comment
        if comment.shouldHideInFeed { return [] }
        if node.collapsed { return [.comment(node)] }
        var output: [CommentTreeViewType] = node.children.reduce([.comment(node)]) { $0 + generateViewTree(for: $1) }
        let directChildCount = node.children.reduce(comment.commentCount) { $0 - $1.comment.commentCount }
        if node.children.count < directChildCount {
            output.append(.unloadedComments(comment: node, count: comment.commentCount - output.count))
        }
        return output
    }

    func topCommentRow(of anchors: AnchorsKey.Value, in proxy: GeometryProxy) -> ActorIdentifier? {
        var yBest = CGFloat.infinity
        var ret: ActorIdentifier?
        for (row, anchor) in anchors {
            let y = proxy[anchor].y
            guard y >= 0, y < yBest else { continue }
            ret = row
            yBest = y
        }
        return ret
    }
    
    func updateAnchors(_ anchors: AnchorsKey.Value, in proxy: GeometryProxy) {
        topVisibleItem.wrappedValue = topCommentRow(of: anchors, in: proxy)
        if (topVisibleItem.wrappedValue == post.actorId) != topVisibleItem.isAtPost {
            topVisibleItem.isAtPost.toggle()
        }
        updateHistory()
    }
    
    private func updateHistory() {
        if let commentActorId = topVisibleItem.wrappedValue, topVisibleItem.wrappedValue != post.actorId {
            expandedPostHistoryTracker.insert(postActorId: post.actorId, commentActorId: commentActorId)
            if let furthestVisitedComment = topVisibleItem.furthestVisitedComment, let tracker {
                let nodes = tracker.nodes.reduce([]) { $0 + $1.tree(hideIfCollapsed: false) }
                let furthestVisitedCommentIndex = nodes.firstIndex { $0.actorId == furthestVisitedComment }
                let newVisitedCommentIndex = nodes.firstIndex { $0.actorId == commentActorId }
                if let furthestVisitedCommentIndex, let newVisitedCommentIndex {
                    if furthestVisitedCommentIndex > newVisitedCommentIndex { return }
                }
            }
            topVisibleItem.furthestVisitedComment = commentActorId
        }
    }
    
    func scrollToLastVisitedPosition() {
        if let furthestVisitedComment = topVisibleItem.furthestVisitedComment {
            jumpButtonTarget = furthestVisitedComment
            return
        }
        
        switch previousVisitRecord {
        case let .revisit(topVisibleCommentAtLastVisit: topVisibleCommentAtLastVisit):
            jumpButtonTarget = topVisibleCommentAtLastVisit
        default:
            break
        }
    }
    
    func scrollToNextComment() {
        guard let tracker else { return }
        if let topVisibleItem = topVisibleItem.wrappedValue {
            if topVisibleItem == post.actorId, let first = tracker.nodes.first {
                jumpButtonTarget = first.actorId
                return
            }
            if let comment = tracker.nodesKeyedByActorId[topVisibleItem] {
                if let topLevelIndex = tracker.nodes.firstIndex(of: comment.topParent) {
                    guard topLevelIndex + 1 < tracker.nodes.count else { return }
                    jumpButtonTarget = tracker.nodes[topLevelIndex + 1].actorId
                }
            }
        }
    }
    
    func scrollToPreviousComment() {
        guard let tracker else { return }
        if let topVisibleItem = topVisibleItem.wrappedValue, topVisibleItem != post.actorId {
            if let comment = tracker.nodesKeyedByActorId[topVisibleItem] {
                if var topLevelIndex = tracker.nodes.firstIndex(of: comment.topParent) {
                    if topLevelIndex < 0 || comment == tracker.nodes.first {
                        jumpButtonTarget = post.actorId
                    } else {
                        if comment.parent == nil { topLevelIndex -= 1 }
                        jumpButtonTarget = tracker.nodes[topLevelIndex].actorId
                    }
                } else {
                    assertionFailure()
                }
            }
        }
    }
}
