//
//  GroupAction.swift
//  Mlem
//
//  Created by Sjmarf on 31/03/2024.
//

import SwiftUI

enum ActionGroupMode {
    case section, compactSection, disclosure, popup
}

struct ActionGroup: Action {
    let id: String = UUID().uuidString
    
    let isOn: Bool
    
    let label: String
    let prompt: String?
    let isDestructive: Bool
    let color: Color
    
    let barIcon: String
    let menuIcon: String
    let swipeIcon1: String
    let swipeIcon2: String
    
    let disabled: Bool
    let children: [any Action]
    
    /// Represents how the children of the `ActionGroup` are presented.
    let displayMode: ActionGroupMode
    
    init(
        isOn: Bool = false,
        label: LocalizedStringResource = "More...",
        prompt: String? = nil,
        color: Color = .blue,
        isDestructive: Bool = false,
        icon: String = Icons.menuCircle,
        barIcon: String? = nil,
        menuIcon: String? = nil,
        swipeIcon1: String? = nil,
        swipeIcon2: String? = nil,
        disabled: Bool? = nil,
        displayMode: ActionGroupMode = .section,
        @ActionBuilder content: () -> [any Action]
    ) {
        self.init(
            isOn: isOn,
            label: String(localized: label),
            prompt: prompt,
            color: color,
            isDestructive: isDestructive,
            icon: icon,
            barIcon: barIcon,
            menuIcon: menuIcon,
            swipeIcon1: swipeIcon1,
            swipeIcon2: swipeIcon2,
            disabled: disabled,
            displayMode: displayMode,
            children: content()
        )
    }

    @_disfavoredOverload // This ensures that the other initialiser takes priority
    init(
        isOn: Bool = false,
        label: String,
        prompt: String? = nil,
        color: Color = .blue,
        isDestructive: Bool = false,
        icon: String = Icons.menuCircle,
        barIcon: String? = nil,
        menuIcon: String? = nil,
        swipeIcon1: String? = nil,
        swipeIcon2: String? = nil,
        disabled: Bool? = nil,
        displayMode: ActionGroupMode = .section,
        children: [any Action]
    ) {
        self.isOn = isOn
        self.label = label
        self.prompt = prompt
        self.isDestructive = isDestructive
        self.color = color
        self.barIcon = barIcon ?? icon
        self.menuIcon = menuIcon ?? icon
        self.swipeIcon1 = swipeIcon1 ?? icon
        self.swipeIcon2 = swipeIcon2 ?? icon
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
