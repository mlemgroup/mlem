//
//  Reply1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 04/07/2024.
//

import MlemMiddleware

extension Reply1Providing {
    private var self2: (any Reply2Providing)? { self as? any Reply2Providing }
    
    @ActionBuilder
    func menuActions(
        appState: AppState,
        navigation: NavigationLayer,
        feedback: Set<FeedbackType> = [.haptic, .toast]
    ) -> [any Action] {
        ActionGroup(displayMode: .compactSection) {
            upvoteAction(appState: appState, feedback: feedback)
            downvoteAction(appState: appState, feedback: feedback)
            saveAction(appState: appState, feedback: feedback)
            replyAction(appState: appState)
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
        case .downvote: api.downvotesEnabled ? downvoteAction(appState: appState, feedback: [.haptic]) : nil
        case .save: saveAction(appState: appState, feedback: [.haptic])
        case .reply: replyAction(appState: appState)
        case .markRead: markReadAction(appState: appState, feedback: [.haptic])
        case .report: reportAction(appState: appState)
        case .selectText: selectTextAction()
        }
    }
    
    func counter(appState: AppState, type: ReplyBarConfiguration.CounterType) -> Counter? {
        switch type {
        case .score: scoreCounter(appState: appState)
        case .upvote: upvoteCounter(appState: appState)
        case .downvote: api.downvotesEnabled ? downvoteCounter(appState: appState) : nil
        case .reply: replyCounter(appState: appState)
        }
    }
    
    func readout(type: ReplyBarConfiguration.ReadoutType, showColor: Bool) -> Readout? {
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
