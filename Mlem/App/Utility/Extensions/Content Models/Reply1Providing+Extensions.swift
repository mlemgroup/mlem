//
//  Reply1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 04/07/2024.
//

import MlemMiddleware

extension Reply1Providing {
    private var self2: (any Reply2Providing)? { self as? any Reply2Providing }
    
    func toggleRead(feedback: Set<FeedbackType>) {
        if feedback.contains(.haptic) {
            HapticManager.main.play(haptic: .lightSuccess, priority: .low)
        }
        toggleRead()
    }
    
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
    
    func markReadAction(feedback: Set<FeedbackType> = []) -> BasicAction {
        .init(
            id: "markRead\(uid)",
            isOn: read,
            label: read ? "Mark Unread" : "Mark Read",
            color: Palette.main.read,
            icon: Icons.upvote,
            menuIcon: read ? Icons.markReadFill : Icons.markRead,
            swipeIcon1: read ? Icons.markRead : Icons.markUnread,
            swipeIcon2: read ? Icons.markUnreadFill : Icons.markReadFill,
            callback: api.willSendToken ? { self.self2?.toggleRead(feedback: feedback) } : nil
        )
    }
}
