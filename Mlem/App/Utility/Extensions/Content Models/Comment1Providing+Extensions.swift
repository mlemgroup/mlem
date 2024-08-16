//
//  Comment1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import Foundation
import MlemMiddleware

extension Comment1Providing {
    var isOwnComment: Bool { creatorId == api.myPerson?.id }

    func swipeActions(
        behavior: SwipeBehavior,
        expandedPostTracker: ExpandedPostTracker? = nil
    ) -> SwipeConfiguration {
        .init(
            behavior: behavior,
            leadingActions: {
                if api.canInteract {
                    upvoteAction(feedback: [.haptic])
                    downvoteAction(feedback: [.haptic])
                }
            },
            trailingActions: {
                if api.canInteract {
                    saveAction(feedback: [.haptic])
                    replyAction(expandedPostTracker: expandedPostTracker)
                }
            }
        )
    }
    
    @ActionBuilder
    func menuActions(
        feedback: Set<FeedbackType> = [.haptic, .toast],
        expandedPostTracker: ExpandedPostTracker? = nil
    ) -> [any Action] {
        ActionGroup(displayMode: .compactSection) {
            upvoteAction(feedback: feedback)
            downvoteAction(feedback: feedback)
            saveAction(feedback: feedback)
            replyAction(expandedPostTracker: expandedPostTracker)
            selectTextAction()
            shareAction()
            
            if self.isOwnComment {
                deleteAction(feedback: feedback)
            } else {
                reportAction()
                blockCreatorAction(feedback: feedback)
            }
        }
    }
    
    func action(
        type: CommentBarConfiguration.ActionType,
        expandedPostTracker: ExpandedPostTracker? = nil
    ) -> any Action {
        switch type {
        case .upvote:
            upvoteAction(feedback: [.haptic])
        case .downvote:
            downvoteAction(feedback: [.haptic])
        case .save:
            saveAction(feedback: [.haptic])
        case .reply:
            replyAction(expandedPostTracker: expandedPostTracker)
        case .share:
            shareAction()
        case .selectText:
            selectTextAction()
        }
    }
    
    func counter(type: CommentBarConfiguration.CounterType) -> Counter {
        switch type {
        case .score:
            scoreCounter
        case .upvote:
            upvoteCounter
        case .downvote:
            downvoteCounter
        }
    }
    
    func readout(type: CommentBarConfiguration.ReadoutType) -> Readout {
        switch type {
        case .created:
            createdReadout
        case .score:
            scoreReadout
        case .upvote:
            upvoteReadout
        case .downvote:
            downvoteReadout
        case .comment:
            commentReadout
        }
    }
}
