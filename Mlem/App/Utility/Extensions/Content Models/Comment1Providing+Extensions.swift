//
//  Comment1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import Foundation
import MlemMiddleware

extension Comment1Providing {
    func swipeActions(behavior: SwipeBehavior) -> SwipeConfiguration {
        let leadingActions: [BasicAction] = api.willSendToken ? [
            upvoteAction(feedback: [.haptic]),
            downvoteAction(feedback: [.haptic])
        ] : .init()
        let trailingActions: [BasicAction] = api.willSendToken ? [
            saveAction(feedback: [.haptic]),
            replyAction()
        ] : .init()
        
        return .init(leadingActions: leadingActions, trailingActions: trailingActions, behavior: behavior)
    }
    
    func menuActions(feedback: Set<FeedbackType> = [.haptic, .toast]) -> ActionGroup {
        ActionGroup(
            children: [
                ActionGroup(
                    children: [
                        upvoteAction(feedback: feedback),
                        downvoteAction(feedback: feedback),
                        saveAction(feedback: feedback),
                        replyAction(),
                        selectTextAction(),
                        shareAction(),
                        blockCreatorAction(feedback: feedback)
                    ],
                    displayMode: .compactSection
                )
            ])
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
