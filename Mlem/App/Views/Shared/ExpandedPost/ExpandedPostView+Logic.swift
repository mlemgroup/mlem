//
//  ExpandedPostView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 24/08/2024.
//

import MlemMiddleware
import SwiftUI

extension ExpandedPostView {
    var showLoadingSymbol: Bool {
        !(scrollTargetedComment == nil || (post is any Post3Providing && scrolledToscrollTargetedComment))
    }
    
    func topCommentRow(of anchors: AnchorsKey.Value, in proxy: GeometryProxy) -> URL? {
        var yBest = CGFloat.infinity
        var ret: URL?
        for (row, anchor) in anchors {
            let y = proxy[anchor].y
            guard y >= 0, y < yBest else { continue }
            ret = row
            yBest = y
        }
        return ret
    }
    
    func scrollToNextComment() {
        guard let tracker else { return }
        if let topVisibleItem {
            if topVisibleItem == post?.actorId, let first = tracker.comments.first {
                jumpButtonTarget = first.actorId
                return
            }
            if let comment = tracker.commentsKeyedByActorId[topVisibleItem] {
                if let topLevelIndex = tracker.comments.firstIndex(of: comment.topParent) {
                    guard topLevelIndex + 1 < tracker.comments.count else { return }
                    jumpButtonTarget = tracker.comments[topLevelIndex + 1].actorId
                }
            }
        }
    }
    
    func scrollToPreviousComment() {
        guard let tracker else { return }
        if let topVisibleItem, topVisibleItem != post?.actorId {
            if let comment = tracker.commentsKeyedByActorId[topVisibleItem] {
                if var topLevelIndex = tracker.comments.firstIndex(of: comment.topParent) {
                    if topLevelIndex < 0 || comment == tracker.comments.first {
                        jumpButtonTarget = post?.actorId
                    } else {
                        if comment.parent == nil { topLevelIndex -= 1 }
                        jumpButtonTarget = tracker.comments[topLevelIndex].actorId
                    }
                } else {
                    assertionFailure()
                }
            }
        }
    }
}
