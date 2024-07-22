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

    func swipeActions(behavior: SwipeBehavior) -> SwipeConfiguration {
        .init(
            behavior: behavior,
            leadingActions: {
                if api.willSendToken {
                    upvoteAction(feedback: [.haptic])
                    downvoteAction(feedback: [.haptic])
                }
            },
            trailingActions: {
                if api.willSendToken {
                    saveAction(feedback: [.haptic])
                    replyAction()
                }
            }
        )
    }
    
    @ActionBuilder
    func menuActions(feedback: Set<FeedbackType> = [.haptic, .toast]) -> [any Action] {
        ActionGroup(displayMode: .compactSection) {
            upvoteAction(feedback: feedback)
            downvoteAction(feedback: feedback)
            saveAction(feedback: feedback)
            replyAction()
            selectTextAction()
            shareAction()
            
            if self.isOwnComment {
                deleteAction(feedback: feedback)
            } else {
                blockCreatorAction(feedback: feedback)
            }
        }
    }
    
    func action(type: CommentActionType) -> any Action {
        switch type {
        case .upvote:
            upvoteAction(feedback: [.haptic])
        case .downvote:
            downvoteAction(feedback: [.haptic])
        case .save:
            saveAction(feedback: [.haptic])
        case .reply:
            replyAction()
        case .share:
            shareAction()
        case .selectText:
            selectTextAction()
        }
    }
    
    func counter(type: CommentCounterType) -> Counter {
        switch type {
        case .score:
            scoreCounter
        case .upvote:
            upvoteCounter
        case .downvote:
            downvoteCounter
        }
    }
    
    func readout(type: CommentReadoutType) -> Readout {
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
