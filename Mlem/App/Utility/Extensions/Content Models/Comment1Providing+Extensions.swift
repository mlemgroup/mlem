//
//  Comment1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import Foundation
import MlemMiddleware
import SwiftUI

extension Comment1Providing {
    private var self2: (any Comment2Providing)? { self as? any Comment2Providing }

    var isOwnComment: Bool { creatorId == api.myPerson?.id }
    
    var shouldHideInFeed: Bool {
        (creator_?.shouldHideInFeed ?? false) || purged
    }
    
    @MainActor
    func showEditSheet() {
        if let self = self as? any Comment2Providing {
            NavigationModel.main.openSheet(.editComment(self.comment2, context: nil))
        }
    }

    var canModerate: Bool {
        guard let id = community_?.id as? Int else { return false }
        return api.myPerson?.moderates(communityId: id) ?? false || api.isAdmin
    }

    @ActionBuilder
    func allMenuActions(
        appState: AppState,
        expanded: Bool = false,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        showAllActions: Bool = true,
        navigation: NavigationLayer?,
        commentTreeTracker: CommentTreeTracker? = nil,
        report: Report? = nil
    ) -> [any Action] {
        basicMenuActions(
            appState: appState,
            feedback: feedback,
            navigation: navigation,
            commentTreeTracker: commentTreeTracker
        )
        if canModerate {
            ActionGroup(
                appearance: .init(label: "Moderation...", color: .themedModeration, icon: Icons.moderation),
                displayMode: Settings.get(\.menus_modActionGrouping) == .divider || expanded ? .section : .disclosure
            ) {
                moderatorMenuActions(appState: appState, feedback: feedback, showAllActions: showAllActions, report: report)
            }
        }
    }
    
    @ActionBuilder
    func basicMenuActions(
        appState: AppState,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        navigation: NavigationLayer?,
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> [any Action] {
        ActionGroup(displayMode: .compactSection) {
            upvoteAction(appState: appState, feedback: feedback)
            downvoteAction(appState: appState, feedback: feedback)
            saveAction(appState: appState, feedback: feedback)
            replyAction(appState: appState, commentTreeTracker: commentTreeTracker)
            if !deleted {
                selectTextAction()
            }
            shareAction(navigation: navigation)
            
            if isOwnComment {
                editAction(appState: appState)
                deleteAction(appState: appState, feedback: feedback)
            } else {
                if !canModerate, !deleted {
                    reportAction(appState: appState)
                }
                blockCreatorAction(appState: appState, feedback: feedback)
            }
        }
    }
    
    @ActionBuilder
    func moderatorMenuActions(
        appState: AppState,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        showAllActions: Bool = true,
        report: Report? = nil
    ) -> [any Action] {
        let viewVotesIsPossible = api.supportsOrElse(.viewVotes, defaultValue: false)
        
        if viewVotesIsPossible, showAllActions || Settings.get(\.menus_allModActions) {
            viewVotesAction()
        }
        if let self2, !isOwnComment {
            self2.removeAction(appState: appState).disabled(!canModerate)
            self2.creator.banActions(appState: appState, community: self2.community, withUserLabel: true)
        }
        if api.isAdmin, api.supportsOrElse(.purgeContent, defaultValue: false) {
            purgeAction(appState: appState)
            if !isOwnComment {
                purgeCreatorAction(appState: appState)
            }
        }
        if let report {
            ActionGroup {
                report.menuActions(appState: appState)
            }
        }
    }
    
    func shouldShowLoadingSymbol(for barConfiguration: CommentBarConfiguration? = nil) -> Bool {
        false
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func action(
        appState: AppState,
        type: CommentBarConfiguration.ActionType,
        navigation: NavigationLayer?,
        commentTreeTracker: CommentTreeTracker? = nil,
        communityContext: (any CommunityStubProviding)? = nil,
        reportContext: Report? = nil
    ) -> (any Action)? {
        switch type {
        case .upvote: upvoteAction(appState: appState, feedback: [.haptic])
        case .downvote: api.downvotesEnabled ? downvoteAction(appState: appState, feedback: [.haptic]) : nil
        case .save: saveAction(appState: appState, feedback: [.haptic])
        case .reply: replyAction(appState: appState, commentTreeTracker: commentTreeTracker)
        case .share: shareAction(navigation: navigation)
        case .selectText: selectTextAction()
        case .report: reportAction(appState: appState, communityContext: communityContext)
        case .resolve: reportContext?.resolveAction(appState: appState, feedback: [.haptic])
        case .remove: removeAction(appState: appState).disabled(!canModerate)
        case .ban: reportContext?.contextualBanAction(appState: appState)
        case .collapse: collapseAction(commentTreeTracker: commentTreeTracker)
        case .collapseParent: collapseParentAction(commentTreeTracker: commentTreeTracker)
        case .collapseToTop: collapseToTopAction(commentTreeTracker: commentTreeTracker)
        }
    }
    
    func counter(
        appState: AppState,
        type: CommentBarConfiguration.CounterType,
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> Counter? {
        switch type {
        case .score: scoreCounter(appState: appState)
        case .upvote: upvoteCounter(appState: appState)
        case .downvote: api.downvotesEnabled ? downvoteCounter(appState: appState) : nil
        case .reply: replyCounter(appState: appState, commentTreeTracker: commentTreeTracker)
        }
    }
    
    func readout(type: CommentBarConfiguration.ReadoutType, showColor: Bool) -> Readout? {
        switch type {
        case .created: createdReadout
        // swiftlint:disable:next void_function_in_ternary
        case .score: api.downvotesEnabled ? scoreReadout(showColor: showColor) : upvoteReadout(showColor: showColor)
        case .upvote: upvoteReadout(showColor: showColor)
        case .downvote: api.downvotesEnabled ? downvoteReadout(showColor: showColor) : nil
        case .comment: commentReadout
        case .saved: savedReadout(showColor: showColor)
        }
    }
    
    // MARK: Actions
    
    func editAction(appState: AppState) -> BasicAction {
        .init(
            id: "edit\(uid)",
            appearance: .edit(),
            callback: api.canInteract(appState: appState) ? { @MainActor in self.showEditSheet() } : nil
        )
    }
    
    func viewVotesAction() -> BasicAction {
        let enabled = canModerate && (api.supportsOrElse(.viewVotes, defaultValue: true))
        let callback: (@MainActor () -> Void)?
        if let self2, enabled {
            callback = {
                NavigationModel.main.openSheet(.votesList(.comment(self2)))
            }
        } else {
            callback = nil
        }
        return .init(
            id: "viewVotes\(uid)",
            appearance: .viewVotes(),
            callback: callback
        )
    }
    
    func collapseAction(commentTreeTracker: CommentTreeTracker? = nil) -> BasicAction {
        .init(
            id: "collapse\(uid)",
            appearance: .collapse(),
            callback: { @MainActor in
                withAnimation(UIAccessibility.isReduceMotionEnabled ? nil : .default) {
                    commentTreeTracker?.nodesKeyedByActorId[self.actorId]?.collapsed.toggle()
                }
            }
        )
    }
    
    func collapseParentAction(commentTreeTracker: CommentTreeTracker? = nil) -> BasicAction {
        .init(
            id: "collapseParent\(uid)",
            appearance: .collapseParent(),
            callback: { @MainActor in
                withAnimation(UIAccessibility.isReduceMotionEnabled ? nil : .default) {
                    guard let comment = commentTreeTracker?.nodesKeyedByActorId[self.actorId] else { return }
                    (comment.parent ?? comment).collapsed.toggle()
                }
            }
        )
    }
    
    func collapseToTopAction(commentTreeTracker: CommentTreeTracker? = nil) -> BasicAction {
        .init(
            id: "collapseToTop\(uid)",
            appearance: .collapseToTop(),
            callback: { @MainActor in
                withAnimation(UIAccessibility.isReduceMotionEnabled ? nil : .default) {
                    commentTreeTracker?.nodesKeyedByActorId[self.actorId]?.topParent.collapsed.toggle()
                }
            }
        )
    }
}
