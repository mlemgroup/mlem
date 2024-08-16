//
//  GroupAction.swift
//  Mlem
//
//  Created by Sjmarf on 31/03/2024.
//

import SwiftUI

struct ActionGroup: Action {
    enum DisplayMode {
        case section, compactSection, disclosure, popup
    }
    
    let id: String = UUID().uuidString
    let appearance: ActionAppearance

    let prompt: String?
    
    let disabled: Bool
    let children: [any Action]
    
    /// Represents how the children of the `ActionGroup` are presented.
    let displayMode: DisplayMode
    
    init(
        appearance: ActionAppearance = .groupDefault,
        prompt: String? = nil,
        disabled: Bool? = nil,
        displayMode: DisplayMode = .section,
        @ActionBuilder children: () -> [any Action]
    ) {
        self.init(
            appearance: appearance,
            prompt: prompt,
            disabled: disabled,
            displayMode: displayMode,
            children: children()
        )
    }
    
    init(
        appearance: ActionAppearance = .groupDefault,
        prompt: String? = nil,
        disabled: Bool? = nil,
        displayMode: DisplayMode = .section,
        children: [any Action]
    ) {
        self.appearance = appearance
        self.prompt = prompt
        self.disabled = disabled ?? !children.allSatisfy { action in
            if let action = action as? BasicAction {
                return !action.disabled
            } else if let action = action as? ActionGroup {
                return !action.disabled
            }
            return true
        }
        self.children = children
        self.displayMode = displayMode
    }
}

private extension ActionAppearance {
    static let groupDefault: Self = .init(label: "More...", color: .gray, icon: Icons.menuCircle)
}
