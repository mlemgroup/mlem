//
//  Message1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/07/2024.
//

import MlemMiddleware

extension Message1Providing {
    var self2: (any Message2Providing)? { self as? any Message2Providing }
        
    func swipeActions(appState: AppState, behavior: SwipeBehavior) -> SwipeConfiguration {
        .init(
            behavior: behavior,
            trailingActions: {
                if api.canInteract(appState: appState), !isOwnMessage {
                    markReadAction(appState: appState, feedback: [.haptic])
                }
            }
        )
    }
    
    @ActionBuilder
    func allMenuActions(
        appState: AppState,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        isInMessageFeed: Bool = false,
        editCallback: (@MainActor () -> Void)?,
        navigation: NavigationLayer? = nil,
        report: Report? = nil
    ) -> [any Action] {
        basicMenuActions(
            appState: appState,
            feedback: feedback,
            isInMessageFeed: isInMessageFeed,
            editCallback: editCallback,
            navigation: navigation
        )
        if api.isAdmin {
            ActionGroup(
                appearance: .init(label: "Moderation...", color: .themedModeration, icon: Icons.moderation),
                displayMode: LegacySettings.main.moderatorActionGrouping == .divider ? .section : .disclosure
            ) {
                moderatorMenuActions(appState: appState, feedback: feedback, report: report)
            }
        }
    }
        
    @ActionBuilder
    func basicMenuActions(
        appState: AppState,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        isInMessageFeed: Bool = false,
        editCallback: (@MainActor () -> Void)?,
        navigation: NavigationLayer? = nil,
        report: Report? = nil
    ) -> [any Action] {
        if !isOwnMessage {
            if let navigation, !isInMessageFeed {
                replyAction(appState: appState, navigation: navigation)
            }
            markReadAction(appState: appState, feedback: feedback)
        }
        if !deleted {
            selectTextAction()
        }
        if isOwnMessage {
            if let editCallback {
                editAction(appState: appState, callback: editCallback)
            }
            deleteAction(appState: appState, feedback: feedback)
        } else {
            if report == nil {
                reportAction(appState: appState)
            }
            if !isInMessageFeed {
                blockCreatorAction(appState: appState, feedback: feedback)
            }
        }
    }
    
    @ActionBuilder
    func moderatorMenuActions(
        appState: AppState,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        report: Report? = nil
    ) -> [any Action] {
        if let report {
            ActionGroup {
                report.menuActions(appState: appState)
            }
        }
    }
    
    func editAction(appState: AppState, callback: @escaping @MainActor () -> Void) -> BasicAction {
        .init(
            id: "edit\(uid)",
            appearance: .edit(),
            callback: api.canInteract(appState: appState) ? callback : nil
        )
    }
    
    // These actions are also defined in Interactable1Providing... another protocol for these may be a good idea
       
    func replyAction(appState: AppState, navigation: NavigationLayer) -> BasicAction {
        var callback: (@MainActor () -> Void)?
        if let creator = creator_, api.canInteract(appState: appState) {
            callback = { @MainActor in navigation.push(.messageFeed(creator, focusTextField: true)) }
        }
        return .init(
            id: "reply\(uid)",
            appearance: .reply(),
            callback: callback
        )
    }
    
    func blockCreatorAction(appState: AppState, feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        .init(
            id: "blockCreator\(uid)",
            appearance: .blockCreator(),
            callback: api.canInteract(appState: appState) ? { @MainActor in self.self2?.creator.toggleBlocked(feedback: feedback) } : nil
        )
    }
}
