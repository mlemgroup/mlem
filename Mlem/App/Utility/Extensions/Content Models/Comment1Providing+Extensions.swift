//
//  Comment1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import Foundation
import MlemMiddleware

extension Comment1Providing {
    private var self2: (any Comment2Providing)? { self as? any Comment2Providing }

    var isOwnComment: Bool { creatorId == api.myPerson?.id }
    
    var shouldHideInFeed: Bool {
        (creator_?.shouldHideInFeed ?? false) || purged
    }
    
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
                    if api.downvotesEnabled {
                        downvoteAction(feedback: [.haptic])
                    }
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
    
    var canModerate: Bool {
        guard let id = community_?.id as? Int else { return false }
        return api.myPerson?.moderates(communityId: id) ?? false || api.isAdmin
    }

    @ActionBuilder
    func allMenuActions(
        expanded: Bool = false,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> [any Action] {
        basicMenuActions(feedback: feedback, commentTreeTracker: commentTreeTracker)
        if canModerate {
            ActionGroup(
                appearance: .init(label: "Moderation...", color: Palette.main.moderation, icon: Icons.moderation),
                displayMode: Settings.main.moderatorActionGrouping == .divider || expanded ? .section : .disclosure
            ) {
                moderatorMenuActions(feedback: feedback)
            }
        }
    }
    
    @ActionBuilder
    func basicMenuActions(
        feedback: Set<FeedbackType> = [.haptic, .toast],
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> [any Action] {
        ActionGroup(displayMode: .compactSection) {
            upvoteAction(feedback: feedback)
            downvoteAction(feedback: feedback)
            saveAction(feedback: feedback)
            replyAction(commentTreeTracker: commentTreeTracker)
            if !deleted {
                selectTextAction()
            }
            shareAction()
            
            if isOwnComment {
                editAction()
                deleteAction(feedback: feedback)
            } else {
                if !canModerate, !deleted {
                    reportAction()
                }
                blockCreatorAction(feedback: feedback)
            }
        }
    }
    
    @ActionBuilder
    func moderatorMenuActions(feedback: Set<FeedbackType> = [.haptic, .toast]) -> [any Action] {
        if let self2, !isOwnComment {
            self2.removeAction().disabled(!canModerate)
            banActions()
        }
        if api.isAdmin {
            purgeAction()
            if !isOwnComment {
                purgeCreatorAction()
            }
        }
    }
    
    func shouldShowLoadingSymbol(for barConfiguration: CommentBarConfiguration? = nil) -> Bool {
        false
    }
    
    func action(
        type: CommentBarConfiguration.ActionType,
        commentTreeTracker: CommentTreeTracker? = nil,
        communityContext: (any CommunityStubProviding)? = nil
    ) -> (any Action)? {
        switch type {
        case .upvote: upvoteAction(feedback: [.haptic])
        case .downvote: api.downvotesEnabled ? downvoteAction(feedback: [.haptic]) : nil
        case .save: saveAction(feedback: [.haptic])
        case .reply: replyAction(commentTreeTracker: commentTreeTracker)
        case .share: shareAction()
        case .selectText: selectTextAction()
        case .report: reportAction(communityContext: communityContext)
        case .remove: removeAction().disabled(!canModerate)
        }
    }
    
    func counter(
        type: CommentBarConfiguration.CounterType,
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> Counter? {
        switch type {
        case .score: scoreCounter
        case .upvote: upvoteCounter
        case .downvote: api.downvotesEnabled ? downvoteCounter : nil
        case .reply: replyCounter(commentTreeTracker: commentTreeTracker)
        }
    }
    
    func readout(type: CommentBarConfiguration.ReadoutType) -> Readout? {
        switch type {
        case .created: createdReadout
        case .score: api.downvotesEnabled ? scoreReadout : upvoteReadout
        case .upvote: upvoteReadout
        case .downvote: api.downvotesEnabled ? downvoteReadout : nil
        case .comment: commentReadout
        }
    }
    
    // MARK: Actions
    
    func editAction() -> BasicAction {
        .init(
            id: "edit\(uid)",
            appearance: .edit(),
            callback: api.canInteract ? { self.showEditSheet() } : nil
        )
    }
}
