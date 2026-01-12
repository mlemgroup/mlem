//
//  Reply1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 04/07/2024.
//

import MlemMiddleware

extension Reply1Providing {
    private var self2: (any Reply2Providing)? { self as? any Reply2Providing }

    var downvotesEnabled: Bool {
        api.voteFederationMode.commentDownvote != .disable
    }
    
    @ActionBuilder
    func menuActions(
        appState: AppState,
        navigation: NavigationLayer,
        feedback: Set<FeedbackType> = [.haptic, .toast]
    ) -> [any Action] {
        ActionGroup(displayMode: .compactSection) {
            upvoteAction(appState: appState, feedback: feedback)
            downvoteAction(appState: appState, feedback: feedback, downvotesEnabled: downvotesEnabled)
            saveAction(appState: appState, feedback: feedback)
            if let replyAction = replyAction(appState: appState) { replyAction }
            markReadAction(appState: appState, feedback: feedback)
            if let comment = self2?.comment {
                if !comment.deleted {
                    comment.selectTextAction()
                }
                comment.shareAction(navigation: navigation)
                if !comment.deleted {
                    reportAction(appState: appState)
                }
            }
            blockCreatorAction(appState: appState, feedback: feedback)
        }
    }

    func action(appState: AppState, type: ReplyBarConfiguration.ActionType) -> (any Action)? {
        switch type {
        case .upvote: upvoteAction(appState: appState, feedback: [.haptic])
        case .downvote: downvotesEnabled ? downvoteAction(appState: appState, feedback: [.haptic], downvotesEnabled: downvotesEnabled) : nil
        case .save: saveAction(appState: appState, feedback: [.haptic])
        case .reply: replyAction(appState: appState)
        case .markRead: markReadAction(appState: appState, feedback: [.haptic])
        case .report: reportAction(appState: appState)
        case .selectText: selectTextAction()
        }
    }
    
    func counter(appState: AppState, type: ReplyBarConfiguration.CounterType) -> Counter? {
        switch type {
        case .score: scoreCounter(appState: appState, downvotesEnabled: downvotesEnabled)
        case .upvote: upvoteCounter(appState: appState)
        case .downvote: downvotesEnabled ? downvoteCounter(appState: appState, downvotesEnabled: downvotesEnabled) : nil
        case .reply: replyCounter(appState: appState)
        }
    }
    
    func readout(type: ReplyBarConfiguration.ReadoutType, showColor: Bool) -> Readout? {
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
    
    // MARK: Actions
    
    func selectTextAction() -> BasicAction {
        let callback: (@MainActor () -> Void)?
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
