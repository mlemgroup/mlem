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
    
    // MARK: - Action Groups
    
    func action(
        appState: AppState,
        type: CommentBarConfiguration.ActionType,
        navigation: NavigationLayer?,
        commentTreeTracker: CommentTreeTracker? = nil,
        communityContext: (any CommunityStubProviding)? = nil,
        reportContext: Report? = nil
    ) -> (any Action)? {
        // TODO: NOW
        nil
//        switch type {
//        case .upvote: upvoteAction(appState: appState, feedback: [.haptic])
//        case .downvote: downvotesEnabled ? downvoteAction(appState: appState, feedback: [.haptic], downvotesEnabled: downvotesEnabled) : nil
//        case .save: saveAction(appState: appState, feedback: [.haptic])
//        case .reply: replyAction(appState: appState, commentTreeTracker: commentTreeTracker)
//        case .share: shareAction(navigation: navigation)
//        case .selectText: selectTextAction()
//        case .report: reportAction(appState: appState, communityContext: communityContext)
//        case .resolve: reportContext?.resolveAction(appState: appState, feedback: [.haptic])
//        case .remove: self2?.removeAction(appState: appState).disabled(!canModerate)
//        case .ban: reportContext?.contextualBanAction(appState: appState)
//        case .collapse: collapseAction(commentTreeTracker: commentTreeTracker)
//        case .collapseParent: collapseParentAction(commentTreeTracker: commentTreeTracker)
//        case .collapseToTop: collapseToTopAction(commentTreeTracker: commentTreeTracker)
//        }
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
        // TODO: NOW
//        basicMenuActions(
//            appState: appState,
//            feedback: feedback,
//            navigation: navigation,
//            notification: notification,
//            commentTreeTracker: commentTreeTracker
//        )
//        if canModerate {
//            ActionGroup(
//                appearance: .init(label: "Moderation...", color: .themedModeration, icon: Icons.moderation),
//                displayMode: Settings.get(\.menus_modActionGrouping) == .divider || expanded ? .section : .disclosure
//            ) {
//                moderatorMenuActions(appState: appState, feedback: feedback, showAllActions: showAllActions, report: report)
//            }
//        }
    }
    
    @ActionBuilder
    func basicMenuActions(
        appState: AppState,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        navigation: NavigationLayer?,
        notification: InboxNotification? = nil,
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> [any Action] {
        // TODO: NOW
//        ActionGroup(displayMode: .compactSection) {
//            if let upvoteAction = upvoteAction(appState: appState, feedback: feedback) { upvoteAction }
//            if let downvoteAction = downvoteAction(
//                appState: appState,
//                feedback: feedback,
//                downvotesEnabled: downvotesEnabled) { downvoteAction}
//            if let saveAction = saveAction(appState: appState, feedback: feedback) { saveAction }
//            replyAction(appState: appState, commentTreeTracker: commentTreeTracker)
//            if let notification {
//                markReadAction(appState: appState, notification: notification, feedback: feedback)
//            }
//            if !deleted {
//                selectTextAction()
//            }
//            shareAction(navigation: navigation)
//            
//            if let navigation, notification == nil {
//                createImageAction(navigation: navigation, commentTreeTracker: commentTreeTracker)
//            }
//            
//            if isOwnComment {
//                editAction(appState: appState)
//                deleteAction(appState: appState, feedback: feedback)
//            } else {
//                if !canModerate, !deleted {
//                    reportAction(appState: appState)
//                }
//                if let blockCreatorAction = blockCreatorAction(appState: appState, feedback: feedback) { blockCreatorAction }
//            }
//        }
    }
    
    @ActionBuilder
    func moderatorMenuActions(
        appState: AppState,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        showAllActions: Bool = true,
        report: Report? = nil
    ) -> [any Action] {
//        let viewVotesIsPossible = api.supports(.viewVotes, defaultValue: false)
//        
//        if viewVotesIsPossible, showAllActions || Settings.get(\.menus_allModActions) {
//            viewVotesAction()
//        }
//        if let self2, !isOwnComment {
//            self2.removeAction(appState: appState).disabled(!canModerate)
//            self2.creator.banActions(appState: appState, community: self2.community, withUserLabel: true)
//        }
//        if api.isAdmin, api.supports(.purgeContent, defaultValue: false) {
//            purgeAction(appState: appState)
//            if !isOwnComment,
//            let purgeCreatorAction = purgeCreatorAction(appState: appState) {
//                purgeCreatorAction
//            }
//        }
//        if let report {
//            ActionGroup {
//                report.menuActions(appState: appState)
//            }
//        }
    }
}
