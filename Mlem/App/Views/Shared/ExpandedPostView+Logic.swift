//
//  ExpandedPostView+Logic.swift
//  Mlem
//
//  Created by Sam Marfleet on 24/08/2024.
//

import SwiftUI

extension ExpandedPostView {
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
        if let topVisibleItem {
            if topVisibleItem == post.wrappedValue.actorId {
                if let first = tracker?.comments.first {
                    jumpButtonTarget = first.actorId
                }
                return
            }
            if let comment = tracker?.commentsKeyedByActorId[topVisibleItem] {
                if let tracker, let topLevelIndex = tracker.comments.firstIndex(of: comment.topParent) {
                    guard topLevelIndex + 1 < tracker.comments.count else { return }
                    jumpButtonTarget = tracker.comments[topLevelIndex + 1].actorId
                }
            }
        }
    }
    
    func scrollToPreviousComment() {
        if let topVisibleItem, topVisibleItem != post.wrappedValue.actorId {
            if let comment = tracker?.commentsKeyedByActorId[topVisibleItem], let tracker {
                if let topLevelIndex = tracker.comments.firstIndex(of: comment.topParent) {
                    if topLevelIndex < 0 || comment == tracker.comments.first {
                        jumpButtonTarget = post.wrappedValue.actorId
                        return
                    }
                    if comment.parent == nil {
                        jumpButtonTarget = tracker.comments[topLevelIndex - 1].actorId
                        return
                    }
                    jumpButtonTarget = tracker.comments[topLevelIndex].actorId
                } else {
                    assertionFailure()
                }
            }
        }
    }
}
