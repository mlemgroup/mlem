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
    let id: UUID = .init()
    
    let isOn: Bool
    
    let label: String
    let isDestructive: Bool
    let color: Color
    
    let barIcon: String
    let menuIcon: String
    let swipeIcon1: String
    let swipeIcon2: String
    
    let enabled: Bool
    let children: [any Action]
    
    /// Represents how the children of the `ActionGroup` are presented.
    let displayMode: ActionGroupMode
    
    init(
        isOn: Bool = false,
        label: String = "More...",
        color: Color = .blue,
        isDestructive: Bool = false,
        barIcon: String = Icons.menuCircle,
        menuIcon: String = Icons.menuCircle,
        swipeIcon1: String = Icons.menuCircle,
        swipeIcon2: String = Icons.menuCircleFill,
        enabled: Bool = true,
        children: [any Action],
        displayMode: ActionGroupMode = .section
    ) {
        self.isOn = isOn
        self.label = label
        self.isDestructive = isDestructive
        self.color = color
        self.barIcon = barIcon
        self.menuIcon = menuIcon
        self.swipeIcon1 = swipeIcon1
        self.swipeIcon2 = swipeIcon2
        self.enabled = enabled
        self.children = children
        self.displayMode = displayMode
    }
}
