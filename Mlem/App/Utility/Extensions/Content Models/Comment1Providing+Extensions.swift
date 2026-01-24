//
//  Comment1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import Haptics
import Foundation
import MlemMiddleware
import SwiftUI

// extension Comment1Providing {
//    private var self2: (any Comment2Providing)? { self as? any Comment2Providing }
//
//    var isOwnComment: Bool { creatorId == api.myPerson?.id }
//    
//    var shouldHideInFeed: Bool {
//        (creator_?.shouldHideInFeed ?? false) || purged
//    }
//    
//    @MainActor
//    func showEditSheet() {
//        if let self = self as? any Comment2Providing {
//            NavigationModel.main.openSheet(.editComment(self.comment2, context: nil))
//        }
//    }
//
//    var canModerate: Bool {
//        guard let id = community_?.id as? Int else { return false }
//        return api.myPerson?.moderates(communityId: id) ?? false || api.isAdmin
//    }
//
//    var downvotesEnabled: Bool {
//        api.voteFederationMode.commentDownvote != .disable
//    }
//
//    @ActionBuilder
//    func allMenuActions(
//        appState: AppState,
//        expanded: Bool = false,
//        feedback: Set<FeedbackType> = [.haptic, .toast],
//        showAllActions: Bool = true,
//        navigation: NavigationLayer?,
//        notification: InboxNotification? = nil,
//        commentTreeTracker: CommentTreeTracker? = nil,
//        report: Report? = nil
//    ) -> [any Action] {
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
//    }
//    
//    @ActionBuilder
//    func basicMenuActions(
//        appState: AppState,
//        feedback: Set<FeedbackType> = [.haptic, .toast],
//        navigation: NavigationLayer?,
//        notification: InboxNotification? = nil,
//        commentTreeTracker: CommentTreeTracker? = nil
//    ) -> [any Action] {
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
//    }
//    
//    @ActionBuilder
//    func moderatorMenuActions(
//        appState: AppState,
//        feedback: Set<FeedbackType> = [.haptic, .toast],
//        showAllActions: Bool = true,
//        report: Report? = nil
//    ) -> [any Action] {
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
//    }
//    
//    func shouldShowLoadingSymbol(for barConfiguration: CommentBarConfiguration? = nil) -> Bool {
//        false
//    }
//
//    func action(
//        appState: AppState,
//        type: CommentBarConfiguration.ActionType,
//        navigation: NavigationLayer?,
//        commentTreeTracker: CommentTreeTracker? = nil,
//        communityContext: (any CommunityStubProviding)? = nil,
//        reportContext: Report? = nil
//    ) -> (any Action)? {
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
//    }
//
//    func action(
//        appState: AppState,
//        type: ReplyBarConfiguration.ActionType,
//        navigation: NavigationLayer?,
//        notification: InboxNotification,
//        commentTreeTracker: CommentTreeTracker? = nil,
//        communityContext: (any CommunityStubProviding)? = nil,
//        reportContext: Report? = nil
//    ) -> (any Action)? {
//        switch type {
//        case .upvote: upvoteAction(appState: appState, feedback: [.haptic])
//        case .downvote: downvotesEnabled ? downvoteAction(appState: appState, feedback: [.haptic], downvotesEnabled: downvotesEnabled) : nil
//        case .save: saveAction(appState: appState, feedback: [.haptic])
//        case .reply: replyAction(appState: appState, commentTreeTracker: commentTreeTracker)
//        case .selectText: selectTextAction()
//        case .report: reportAction(appState: appState, communityContext: communityContext)
//        case .markRead: markReadAction(appState: appState, notification: notification)
//        }
//    }
//    
//    func counter(
//        appState: AppState,
//        type: CommentBarConfiguration.CounterType,
//        commentTreeTracker: CommentTreeTracker? = nil
//    ) -> Counter? {
//        switch type {
//        case .score: scoreCounter(appState: appState, downvotesEnabled: downvotesEnabled)
//        case .upvote: upvoteCounter(appState: appState)
//        case .downvote: downvotesEnabled ? downvoteCounter(appState: appState, downvotesEnabled: downvotesEnabled) : nil
//        case .reply: replyCounter(appState: appState, commentTreeTracker: commentTreeTracker)
//        }
//    }
//
//    func counter(
//        appState: AppState,
//        type: ReplyBarConfiguration.CounterType,
//        commentTreeTracker: CommentTreeTracker? = nil
//    ) -> Counter? {
//        switch type {
//        case .score: scoreCounter(appState: appState, downvotesEnabled: downvotesEnabled)
//        case .upvote: upvoteCounter(appState: appState)
//        case .downvote: downvotesEnabled ? downvoteCounter(appState: appState, downvotesEnabled: downvotesEnabled) : nil
//        case .reply: replyCounter(appState: appState, commentTreeTracker: commentTreeTracker)
//        }
//    }
//    
//    func readout(type: CommentBarConfiguration.ReadoutType, showColor: Bool) -> Readout? {
//        switch type {
//        case .created: createdReadout
//        // wiftlint:disable:next void_function_in_ternary
//        case .score: downvotesEnabled ? scoreReadout(showColor: showColor) : upvoteReadout(showColor: showColor)
//        case .upvote: upvoteReadout(showColor: showColor)
//        case .downvote: downvotesEnabled ? downvoteReadout(showColor: showColor) : nil
//        case .comment: commentReadout
//        case .saved: savedReadout(showColor: showColor)
//        }
//    }
//
//    func readout(type: ReplyBarConfiguration.ReadoutType, showColor: Bool) -> Readout? {
//        switch type {
//        case .created: createdReadout
//        // wiftlint:disable:next void_function_in_ternary
//        case .score: downvotesEnabled ? scoreReadout(showColor: showColor) : upvoteReadout(showColor: showColor)
//        case .upvote: upvoteReadout(showColor: showColor)
//        case .downvote: downvotesEnabled ? downvoteReadout(showColor: showColor) : nil
//        case .comment: commentReadout
//        case .saved: savedReadout(showColor: showColor)
//        }
//    }
//    
//    // MARK: Actions
//    
//    func createImageAction(navigation: NavigationLayer, commentTreeTracker: CommentTreeTracker?) -> BasicAction {
//        .init(
//            id: "exportAsImage\(uid)",
//            appearance: .createImage()) {
//                navigation.openSheet(.exportCommentImage(self, tracker: commentTreeTracker))
//            }
//    }
//    
//    func editAction(appState: AppState) -> BasicAction {
//        .init(
//            id: "edit\(uid)",
//            appearance: .edit(),
//            callback: api.canInteract(appState: appState) ? { @MainActor in self.showEditSheet() } : nil
//        )
//    }
//    
//    func viewVotesAction() -> BasicAction {
//        let enabled = canModerate && api.supports(.viewVotes, defaultValue: true)
//        let callback: (@MainActor () -> Void)?
//        if let self2, enabled {
//            callback = {
//                NavigationModel.main.openSheet(.votesList(.comment(self2)))
//            }
//        } else {
//            callback = nil
//        }
//        return .init(
//            id: "viewVotes\(uid)",
//            appearance: .viewVotes(),
//            callback: callback
//        )
//    }
//
//    func markReadAction(appState: AppState, notification: InboxNotification, feedback: Set<FeedbackType> = []) -> BasicAction {
//        .init(
//            id: "markRead\(uid)",
//            appearance: .markRead(isOn: notification.read),
//            callback: api.canInteract(appState: appState) ? {
//                @MainActor in
//                notification.toggleRead()
//                HapticManager.main.play(haptic: .lightSuccess, tier: .low)
//            } : nil
//        )
//    }
//    
//    func collapseAction(commentTreeTracker: CommentTreeTracker? = nil) -> BasicAction {
//        .init(
//            id: "collapse\(uid)",
//            appearance: .collapse(),
//            callback: { @MainActor in
//                withAnimation(UIAccessibility.isReduceMotionEnabled ? nil : .default) {
//                    commentTreeTracker?.nodesKeyedByActorId[self.actorId]?.collapsed.toggle()
//                }
//            }
//        )
//    }
//    
//    func collapseParentAction(commentTreeTracker: CommentTreeTracker? = nil) -> BasicAction {
//        .init(
//            id: "collapseParent\(uid)",
//            appearance: .collapseParent(),
//            callback: { @MainActor in
//                withAnimation(UIAccessibility.isReduceMotionEnabled ? nil : .default) {
//                    guard let comment = commentTreeTracker?.nodesKeyedByActorId[self.actorId] else { return }
//                    (comment.parent ?? comment).collapsed.toggle()
//                }
//            }
//        )
//    }
//    
//    func collapseToTopAction(commentTreeTracker: CommentTreeTracker? = nil) -> BasicAction {
//        .init(
//            id: "collapseToTop\(uid)",
//            appearance: .collapseToTop(),
//            callback: { @MainActor in
//                withAnimation(UIAccessibility.isReduceMotionEnabled ? nil : .default) {
//                    commentTreeTracker?.nodesKeyedByActorId[self.actorId]?.topParent.collapsed.toggle()
//                }
//            }
//        )
//    }
// }
