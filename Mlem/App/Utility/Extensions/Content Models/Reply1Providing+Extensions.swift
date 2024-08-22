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
                    markReadAction(feedback: [.haptic])
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
            markReadAction(feedback: feedback)
            if let comment = self2?.comment {
                comment.selectTextAction()
                comment.shareAction()
            }
            reportAction()
            blockCreatorAction(feedback: feedback)
        }
    }

    func action(type: ReplyBarConfiguration.ActionType) -> any Action {
        switch type {
        case .upvote: upvoteAction(feedback: [.haptic])
        case .downvote: downvoteAction(feedback: [.haptic])
        case .save: saveAction(feedback: [.haptic])
        case .reply: replyAction()
        case .markRead: markReadAction(feedback: [.haptic])
        case .report: reportAction()
        case .selectText: selectTextAction()
        }
    }
    
    func counter(type: ReplyBarConfiguration.CounterType) -> Counter {
        switch type {
        case .score: scoreCounter
        case .upvote: upvoteCounter
        case .downvote: downvoteCounter
        case .reply: replyCounter()
        }
    }
    
    func readout(type: ReplyBarConfiguration.ReadoutType) -> Readout {
        switch type {
        case .created: createdReadout
        case .score: scoreReadout
        case .upvote: upvoteReadout
        case .downvote: downvoteReadout
        case .comment: commentReadout
        }
    }
    
    // MARK: Actions
    
    func selectTextAction() -> BasicAction {
        let callback: (() -> Void)?
        if let comment = comment_ {
            callback = comment.showTextSelectionSheet
        } else {
            callback = nil
        }
        return .init(
            id: "selectText\(id)",
            appearance: .selectText(),
            callback: callback
        )
    }
}
