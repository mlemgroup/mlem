//
//  Reply1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 04/07/2024.
//

import MlemMiddleware

extension Reply1Providing {
    private var self2: (any Reply2Providing)? { self as? any Reply2Providing }
    
    func swipeActions(behavior: SwipeBehavior) -> SwipeConfiguration {
        let leadingActions: [BasicAction] = api.willSendToken ? [
            upvoteAction(feedback: [.haptic]),
            downvoteAction(feedback: [.haptic])
        ] : .init()
        let trailingActions: [BasicAction] = api.willSendToken ? [
            markReadAction(feedback: [.haptic])
        ] : .init()
        
        return .init(leadingActions: leadingActions, trailingActions: trailingActions, behavior: behavior)
    }
    
    @ActionBuilder
    func menuActions(feedback: Set<FeedbackType> = [.haptic, .toast]) -> [any Action] {
        ActionGroup(displayMode: .compactSection) {
            upvoteAction(feedback: feedback)
            downvoteAction(feedback: feedback)
            saveAction(feedback: feedback)
            replyAction()
            markReadAction(feedback: feedback)
            if let comment = self2?.comment {
                comment.selectTextAction()
                comment.shareAction()
            }
            blockCreatorAction(feedback: feedback)
        }
    }

    func action(type: InboxActionType) -> any Action {
        switch type {
        case .upvote:
            upvoteAction(feedback: [.haptic])
        case .downvote:
            downvoteAction(feedback: [.haptic])
        case .save:
            saveAction(feedback: [.haptic])
        }
    }
    
    func counter(type: InboxCounterType) -> Counter {
        switch type {
        case .score:
            scoreCounter
        case .upvote:
            upvoteCounter
        case .downvote:
            downvoteCounter
        }
    }
    
    func readout(type: InboxReadoutType) -> Readout {
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
