//
//  File.swift
//  QuickSwipes
//
//  Created by Sjmarf on 2025-08-22.
//

import Foundation
import Icons
import Theming

public struct QuickSwipeAction {
    enum ActionType {
        case callback(@MainActor () -> Void, confirmationPrompt: String?)
        case choice(QuickSwipeChoiceGroup)
    }
    
    var enabled: Bool
    var perform: ActionType
    
    var color: ThemedColor
    var icon: Icon
    
    public init(
        icon: Icon,
        color: ThemedColor,
        enabled: Bool,
        confirmationPrompt: String?,
        callback: @MainActor @escaping () -> Void
    ) {
        self.icon = icon
        self.color = color
        self.enabled = enabled
        self.perform = .callback(callback, confirmationPrompt: confirmationPrompt)
    }
    
    public init(
        icon: Icon,
        color: ThemedColor,
        enabled: Bool,
        alertTitle: LocalizedStringResource,
        choices: [QuickSwipeChoice]
    ) {
        self.icon = icon
        self.color = color
        self.enabled = enabled
        self.perform = .choice(.init(title: .init(localized: alertTitle), items: choices))
    }
    
    @_disfavoredOverload
    public init(
        icon: Icon,
        color: ThemedColor,
        enabled: Bool,
        alertTitle: String,
        choices: [QuickSwipeChoice]
    ) {
        self.icon = icon
        self.color = color
        self.enabled = enabled
        self.perform = .choice(.init(title: alertTitle, items: choices))
    }
}

struct QuickSwipeChoiceGroup {
    let title: String
    let items: [QuickSwipeChoice]
}

public struct QuickSwipeChoice {
    let label: String
    let destructive: Bool
    let callback: () -> Void
    
    public init(
        label: LocalizedStringResource,
        destructive: Bool = false,
        callback: @escaping () -> Void
    ) {
        self.label = .init(localized: label)
        self.destructive = destructive
        self.callback = callback
    }
    
    @_disfavoredOverload
    public init(
        label: String,
        destructive: Bool = false,
        callback: @escaping () -> Void
    ) {
        self.label = label
        self.destructive = destructive
        self.callback = callback
    }
}
