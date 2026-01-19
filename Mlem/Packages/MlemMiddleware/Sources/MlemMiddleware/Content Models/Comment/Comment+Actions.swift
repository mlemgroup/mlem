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
}
