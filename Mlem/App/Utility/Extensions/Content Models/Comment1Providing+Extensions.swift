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
        commentTreeTracker: CommentTreeTracker? = nil
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
                    replyAction(commentTreeTracker: commentTreeTracker)
                }
            }
        )
    }
    
    @ActionBuilder
    func menuActions(
        feedback: Set<FeedbackType> = [.haptic, .toast],
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> [any Action] {
        ActionGroup(displayMode: .compactSection) {
            upvoteAction(feedback: feedback)
            downvoteAction(feedback: feedback)
            saveAction(feedback: feedback)
            replyAction(commentTreeTracker: commentTreeTracker)
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
        type: CommentBarConfiguration.ActionType,
        commentTreeTracker: CommentTreeTracker? = nil,
        communityContext: (any CommunityStubProviding)? = nil
    ) -> any Action {
        switch type {
        case .upvote: upvoteAction(feedback: [.haptic])
        case .downvote: downvoteAction(feedback: [.haptic])
        case .save: saveAction(feedback: [.haptic])
        case .reply: replyAction(commentTreeTracker: commentTreeTracker)
        case .share: shareAction()
        case .selectText: selectTextAction()
        case .report: reportAction(communityContext: communityContext)
        }
    }
    
    func counter(
        type: CommentBarConfiguration.CounterType,
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> Counter {
        switch type {
        case .score: scoreCounter
        case .upvote: upvoteCounter
        case .downvote: downvoteCounter
        case .reply: replyCounter(commentTreeTracker: commentTreeTracker)
        }
    }
    
    func readout(type: CommentBarConfiguration.ReadoutType) -> Readout {
        switch type {
        case .created: createdReadout
        case .score: scoreReadout
        case .upvote: upvoteReadout
        case .downvote: downvoteReadout
        case .comment: commentReadout
        }
    }
    
    // MARK: Actions
    
    func editAction(feedback: Set<FeedbackType>) -> BasicAction {
        .init(
            id: "edit\(uid)",
            appearance: .init(label: "Edit", color: Palette.main.accent, icon: Icons.edit),
            callback: api.canInteract ? { self.showEditSheet() } : nil
        )
    }
}
