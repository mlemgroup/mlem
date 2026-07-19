//
//  Comment+Actions.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-19.
//

import Haptics
import Foundation
import MlemMiddleware
import SwiftUI

extension Comment {
    // MARK: - Readouts
    
    func readout(type: ReadoutType, showColor: Bool) -> Readout? {
        switch type {
        case .created: createdReadout
        // swiftlint:disable:next void_function_in_ternary
        case .score: downvotesEnabled ? scoreReadout(showColor: showColor) : upvoteReadout(showColor: showColor)
        case .upvote: upvoteReadout(showColor: showColor)
        case .downvote: downvotesEnabled ? downvoteReadout(showColor: showColor) : nil
        case .comment: commentReadout
        case .saved: savedReadout(showColor: showColor)
        }
    }

    // MARK: - Counters
    
    func counter(
        appState: AppState,
        type: CommentBarConfiguration.CounterType,
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> Counter? {
        switch type {
        case .score: scoreCounter(appState: appState, downvotesEnabled: downvotesEnabled)
        case .upvote: upvoteCounter(appState: appState)
        case .downvote: downvotesEnabled ? downvoteCounter(appState: appState, downvotesEnabled: downvotesEnabled) : nil
        case .reply: replyCounter(appState: appState, commentTreeTracker: commentTreeTracker)
        }
    }

    func counter(
        appState: AppState,
        type: ReplyBarConfiguration.CounterType,
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> Counter? {
        switch type {
        case .score: scoreCounter(appState: appState, downvotesEnabled: downvotesEnabled)
        case .upvote: upvoteCounter(appState: appState)
        case .downvote: downvotesEnabled ? downvoteCounter(appState: appState, downvotesEnabled: downvotesEnabled) : nil
        case .reply: replyCounter(appState: appState, commentTreeTracker: commentTreeTracker)
        }
    }
    
    // MARK: - Actions
    
    func createImageAction(navigation: NavigationLayer, commentTreeTracker: CommentTreeTracker?) -> BasicAction {
        .init(
            id: "exportAsImage\(uid)",
            appearance: .createImage()) {
                navigation.openSheet(.exportCommentImage(self, tracker: commentTreeTracker))
            }
    }
    
    func editAction(appState: AppState) -> BasicAction {
        .init(
            id: "edit\(uid)",
            appearance: .edit(),
            callback: api.canInteract(appState: appState)
            ? { @MainActor in NavigationModel.main.openSheet(.editComment(self, context: nil)) }
            : nil
        )
    }
    
    func viewVotesAction() -> BasicAction {
        let callback: (@MainActor () -> Void)? = canModerate
        ? { @MainActor in NavigationModel.main.openSheet(.votesList(.comment(self))) }
        : nil
        return .init(
            id: "viewVotes\(uid)",
            appearance: .viewVotes(),
            callback: callback
        )
    }
    
    func markReadAction(appState: AppState, notification: InboxNotification, feedback: Set<FeedbackType> = []) -> BasicAction {
        .init(
            id: "markRead\(uid)",
            appearance: .markRead(isOn: notification.read),
            callback: api.canInteract(appState: appState) ? {
                @MainActor in
                notification.toggleRead()
                HapticManager.main.play(haptic: .lightSuccess, tier: .low)
            } : nil
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
    
    // MARK: - Action Groups
    
    // swiftlint:disable:next cyclomatic_complexity
    func action(
        appState: AppState,
        type: CommentBarConfiguration.ActionType,
        navigation: NavigationLayer?,
        commentTreeTracker: CommentTreeTracker? = nil,
        communityContext: Community? = nil,
        reportContext: Report? = nil
    ) -> (any Action)? {
        switch type {
        case .upvote: if let upvoteAction = upvoteAction(appState: appState, feedback: [.haptic]) { return upvoteAction }
        case .downvote: if let downvoteAction = downvoteAction(appState: appState, feedback: [.haptic]) { return downvoteAction }
        case .save: return saveAction(appState: appState, feedback: [.haptic])
        case .reply: return replyAction(appState: appState, commentTreeTracker: commentTreeTracker)
        case .share: return shareAction(navigation: navigation)
        case .selectText: return selectTextAction()
        case .report: return reportAction(appState: appState, communityContext: communityContext)
        case .resolve: return reportContext?.resolveAction(appState: appState, feedback: [.haptic])
        case .remove: return removeAction(appState: appState)
        case .ban: return reportContext?.contextualBanAction(appState: appState)
        case .collapse: return collapseAction(commentTreeTracker: commentTreeTracker)
        case .collapseParent: return collapseParentAction(commentTreeTracker: commentTreeTracker)
        case .collapseToTop: return collapseToTopAction(commentTreeTracker: commentTreeTracker)
        }
        return nil
    }
    
    func action(
        appState: AppState,
        type: ReplyBarConfiguration.ActionType,
        navigation: NavigationLayer?,
        notification: InboxNotification,
        commentTreeTracker: CommentTreeTracker? = nil,
        communityContext: Community? = nil,
        reportContext: Report? = nil
    ) -> (any Action)? {
        switch type {
        case .upvote: if let upvoteAction = upvoteAction(appState: appState, feedback: [.haptic]) { return upvoteAction }
        case .downvote: if let downvoteAction = downvoteAction(appState: appState, feedback: [.haptic]) { return downvoteAction }
        case .save: return saveAction(appState: appState, feedback: [.haptic])
        case .reply: return replyAction(appState: appState, commentTreeTracker: commentTreeTracker)
        case .selectText: return selectTextAction()
        case .report: return reportAction(appState: appState, communityContext: communityContext)
        case .markRead: return markReadAction(appState: appState, notification: notification)
        }
        return nil
    }
    
    // MARK: - Action Groups
    
    @ActionBuilder
    func allMenuActions(
        appState: AppState,
        expanded: Bool = false,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        showAllActions: Bool = true,
        navigation: NavigationLayer?,
        notification: InboxNotification? = nil,
        commentTreeTracker: CommentTreeTracker? = nil,
        report: Report? = nil
    ) -> [any Action] {
        basicMenuActions(
            appState: appState,
            feedback: feedback,
            navigation: navigation,
            notification: notification,
            commentTreeTracker: commentTreeTracker
        )
        if canModerate {
            ActionGroup(
                appearance: .init(label: "Moderation...", color: .themedModeration, icon: Icons.moderation),
                displayMode: Settings.get(\.menus_modActionGrouping) == .combined || expanded ? .section : .disclosure
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
        notification: InboxNotification? = nil,
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> [any Action] {
        ActionGroup(displayMode: .compactSection) {
            if let upvoteAction = upvoteAction(appState: appState, feedback: feedback) { upvoteAction }
            if let downvoteAction = downvoteAction(
                appState: appState,
                feedback: feedback) { downvoteAction }
            if let saveAction = saveAction(appState: appState, feedback: feedback) { saveAction }
            replyAction(appState: appState, commentTreeTracker: commentTreeTracker)
            if let notification {
                markReadAction(appState: appState, notification: notification, feedback: feedback)
            }
            if !deleted {
                selectTextAction()
            }
            shareAction(navigation: navigation)
            
            if let navigation, notification == nil {
                createImageAction(navigation: navigation, commentTreeTracker: commentTreeTracker)
            }
            
            if isOwnComment {
                editAction(appState: appState)
                deleteAction(appState: appState, feedback: feedback)
            } else {
                if !canModerate, !deleted {
                    reportAction(appState: appState)
                }
                if let blockCreatorAction = blockCreatorAction(appState: appState, feedback: feedback) { blockCreatorAction }
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
        if showAllActions || Settings.get(\.menus_allModActions) {
            viewVotesAction()
        }
        if !isOwnComment {
            removeAction(appState: appState).disabled(!canModerate)
            if let creator = creator.value, let community = community.value {
                creator.banActions(appState: appState, community: community, withUserLabel: true)
            }
        }
        if api.isAdmin, api.supports(.purgeContent, defaultValue: false) {
            purgeAction(appState: appState)
            if !isOwnComment,
            let purgeCreatorAction = purgeCreatorAction(appState: appState) {
                purgeCreatorAction
            }
        }
        if let report {
            ActionGroup {
                report.menuActions(appState: appState)
            }
        }
    }
}
