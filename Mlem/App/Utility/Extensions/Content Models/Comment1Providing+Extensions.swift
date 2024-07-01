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
        let leadingActions: [BasicAction] = api.willSendToken ? [upvoteAction, downvoteAction] : .init()
        let trailingActions: [BasicAction] = api.willSendToken ? [saveAction] : .init()
        
        return .init(leadingActions: leadingActions, trailingActions: trailingActions, behavior: behavior)
    }
    
    var menuActions: ActionGroup {
        ActionGroup(
            children: [
                ActionGroup(
                    children: [upvoteAction, downvoteAction]
                ),
                saveAction
            ])
    }
    
    func action(type: CommentActionType) -> any Action {
        switch type {
        case .upvote:
            upvoteAction
        case .downvote:
            downvoteAction
        case .save:
            saveAction
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
