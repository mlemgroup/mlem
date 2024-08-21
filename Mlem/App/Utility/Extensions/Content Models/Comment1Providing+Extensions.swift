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
    
    func showEditSheet() {
        if let self = self as? any Comment2Providing {
            NavigationModel.main.openSheet(.editComment(self.comment2, context: nil))
        }
    }

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
                editAction(feedback: feedback)
                deleteAction(feedback: feedback)
            } else {
                reportAction()
                blockCreatorAction(feedback: feedback)
            }
        }
    }
    
    func action(
        type: CommentActionType,
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
    
    // MARK: Actions
    
    func editAction(feedback: Set<FeedbackType>) -> BasicAction {
        .init(
            id: "edit\(uid)",
            isOn: false,
            label: "Edit",
            color: Palette.main.accent,
            icon: Icons.edit,
            callback: api.canInteract ? { self.showEditSheet() } : nil
        )
    }
}
