//
//  Message1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/07/2024.
//

import MlemMiddleware

extension Message1Providing {
    var self2: (any Message2Providing)? { self as? any Message2Providing }
    
    func swipeActions(behavior: SwipeBehavior) -> SwipeConfiguration {
        let trailingActions: [BasicAction] = api.willSendToken ? [
            markReadAction(feedback: [.haptic])
        ] : .init()
        
        return .init(leadingActions: [], trailingActions: trailingActions, behavior: behavior)
    }
    
    @ActionBuilder
    func menuActions(feedback: Set<FeedbackType> = [.haptic, .toast]) -> [any Action] {
        replyAction()
        markReadAction(feedback: feedback)
        selectTextAction()
        blockCreatorAction(feedback: feedback)
    }
    
    // These actions are also defined in Interactable1Providing... another protocol for these may be a good idea
       
    func replyAction() -> BasicAction {
        .init(
            id: "reply\(uid)",
            isOn: false,
            label: "Reply",
            color: Palette.main.accent,
            icon: Icons.reply,
            menuIcon: Icons.reply,
            swipeIcon1: Icons.reply,
            swipeIcon2: Icons.replyFill,
            callback: nil
        )
    }
    
    func blockCreatorAction(feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        .init(
            id: "blockCreator\(uid)",
            isOn: false,
            label: "Block User",
            color: Palette.main.negative,
            isDestructive: true,
            confirmationPrompt: showConfirmation ? "Really block this user?" : nil,
            icon: Icons.hide,
            callback: api.willSendToken ? { self.self2?.creator.toggleBlocked(feedback: feedback) } : nil
        )
    }
}
