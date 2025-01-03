//
//  Message1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/07/2024.
//

import MlemMiddleware

extension Message1Providing {
    var self2: (any Message2Providing)? { self as? any Message2Providing }
        
    func swipeActions(behavior: SwipeBehavior) -> SwipeConfiguration {
        .init(
            behavior: behavior,
            trailingActions: {
                if api.canInteract, !isOwnMessage {
                    markReadAction(feedback: [.haptic])
                }
            }
        )
    }
    
    @ActionBuilder
    func allMenuActions(
        feedback: Set<FeedbackType> = [.haptic, .toast],
        isInMessageFeed: Bool = false,
        editCallback: (@MainActor () -> Void)?,
        navigation: NavigationLayer? = nil,
        report: Report? = nil
    ) -> [any Action] {
        basicMenuActions(
            feedback: feedback,
            isInMessageFeed: isInMessageFeed,
            editCallback: editCallback,
            navigation: navigation
        )
        if api.isAdmin {
            ActionGroup(
                appearance: .init(label: "Moderation...", color: Palette.main.moderation, icon: Icons.moderation),
                displayMode: Settings.main.moderatorActionGrouping == .divider ? .section : .disclosure
            ) {
                moderatorMenuActions(feedback: feedback, report: report)
            }
        }
    }
        
    @ActionBuilder
    func basicMenuActions(
        feedback: Set<FeedbackType> = [.haptic, .toast],
        isInMessageFeed: Bool = false,
        editCallback: (@MainActor () -> Void)?,
        navigation: NavigationLayer? = nil,
        report: Report? = nil
    ) -> [any Action] {
        if !isOwnMessage {
            if let navigation, !isInMessageFeed {
                replyAction(navigation: navigation)
            }
            markReadAction(feedback: feedback)
        }
        if !deleted {
            selectTextAction()
        }
        if isOwnMessage {
            if let editCallback {
                editAction(callback: editCallback)
            }
            deleteAction(feedback: feedback)
        } else {
            if report == nil {
                reportAction()
            }
            if !isInMessageFeed {
                blockCreatorAction(feedback: feedback)
            }
        }
    }
    
    @ActionBuilder
    func moderatorMenuActions(
        feedback: Set<FeedbackType> = [.haptic, .toast],
        report: Report? = nil
    ) -> [any Action] {
        if let report {
            ActionGroup {
                report.menuActions()
            }
        }
    }
    
    func editAction(callback: @escaping @MainActor () -> Void) -> BasicAction {
        .init(
            id: "edit\(uid)",
            appearance: .edit(),
            callback: api.canInteract ? callback : nil
        )
    }
    
    // These actions are also defined in Interactable1Providing... another protocol for these may be a good idea
       
    func replyAction(navigation: NavigationLayer) -> BasicAction {
        var callback: (@MainActor () -> Void)?
        if let creator = creator_, api.canInteract {
            callback = { @MainActor in navigation.push(.messageFeed(creator, focusTextField: true)) }
        }
        return .init(
            id: "reply\(uid)",
            appearance: .reply(),
            callback: callback
        )
    }
    
    func blockCreatorAction(feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        .init(
            id: "blockCreator\(uid)",
            appearance: .blockCreator(),
            callback: api.canInteract ? { @MainActor in self.self2?.creator.toggleBlocked(feedback: feedback) } : nil
        )
    }
}
