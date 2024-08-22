//
//  Message1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/07/2024.
//

import MlemMiddleware

extension Message1Providing {
    var self2: (any Message2Providing)? { self as? any Message2Providing }
    
    var isOwnMessage: Bool { creatorId == api.myPerson?.id }
    
    func swipeActions(behavior: SwipeBehavior) -> SwipeConfiguration {
        .init(
            behavior: behavior,
            trailingActions: {
                if api.canInteract, !isOwnMessage {
                    markReadAction(feedback: [.haptic])
                }
            }
        )
    }
    
    @ActionBuilder
    func menuActions(feedback: Set<FeedbackType> = [.haptic, .toast]) -> [any Action] {
        if !isOwnMessage {
            replyAction()
            markReadAction(feedback: feedback)
        }
        selectTextAction()
        if isOwnMessage {
            deleteAction(feedback: feedback)
        } else {
            reportAction()
            blockCreatorAction(feedback: feedback)
        }
    }
    
    // These actions are also defined in Interactable1Providing... another protocol for these may be a good idea
       
    func replyAction() -> BasicAction {
        .init(
            id: "reply\(uid)",
            appearance: .reply(),
            callback: nil
        )
    }
    
    func blockCreatorAction(feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        .init(
            id: "blockCreator\(uid)",
            appearance: .blockCreator(),
            callback: api.canInteract ? { self.self2?.creator.toggleBlocked(feedback: feedback) } : nil
        )
    }
}
