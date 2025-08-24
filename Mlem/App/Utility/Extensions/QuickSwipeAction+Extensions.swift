//
//  QuickSwipeAction+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-08-22.
//

import Icons
import QuickSwipes

extension QuickSwipeAction {
    init?(from action: any Action) {
        switch action {
        case let action as BasicAction:
            self.init(action: action)
        case let group as ActionGroup:
            self.init(group: group)
        default:
            assertionFailure()
            return nil
        }
    }
    
    private init(action: BasicAction) {
        self.init(
            icon: .init(from: action.appearance),
            color: action.appearance.color,
            enabled: action.callback != nil,
            confirmationPrompt: action.confirmationPrompt,
            callback: action.callback ?? {}
        )
    }
    
    private init(group: ActionGroup) {
        self.init(
            icon: .init(from: group.appearance),
            color: group.appearance.color,
            enabled: true,
            alertTitle: group.prompt ?? "",
            choices: group.children.compactMap(QuickSwipeChoice.init)
        )
    }
}

extension QuickSwipeChoice {
    init?(from action: any Action) {
        switch action {
        case let action as BasicAction:
            self.init(
                label: action.appearance.label,
                destructive: action.appearance.isDestructive,
                callback: action.callback ?? {}
            )
        default:
            assertionFailure()
            return nil
        }
    }
}

// Temporary shim. Eventually the action system will use Icon rather than String and this can be removed
private extension Icon {
    init(from appearance: ActionAppearance) {
        self = .custom { variant in
            switch variant {
            case .active:
                return appearance.swipeIcon2
            case .inactive:
                return appearance.swipeIcon1
            default:
                assertionFailure()
                return appearance.swipeIcon1
            }
        }
    }
}
