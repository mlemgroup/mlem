//
//  ExpandedPostView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 24/08/2024.
//

import MlemMiddleware
import SwiftUI

extension ExpandedPostView {
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
    
    var showLoadingSymbol: Bool {
        !(scrollTargetedComment == nil || (post is any Post3Providing && scrolledToscrollTargetedComment))
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
    
    func scrollToNextComment() {
        guard let tracker, let postActorId = post?.actorId_ else { return }
        if let topVisibleItem {
            if topVisibleItem == postActorId, let first = tracker.nodes.first {
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
        guard let tracker, let postActorId = post?.actorId_ else { return }
        if let topVisibleItem, topVisibleItem != postActorId {
            if let comment = tracker.nodesKeyedByActorId[topVisibleItem] {
                if var topLevelIndex = tracker.nodes.firstIndex(of: comment.topParent) {
                    if topLevelIndex < 0 || comment == tracker.nodes.first {
                        jumpButtonTarget = postActorId
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
