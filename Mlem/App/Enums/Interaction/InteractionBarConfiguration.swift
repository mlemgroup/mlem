//
//  InteractionBarConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 2026-07-24.
//

import Actions
import SwiftUI

protocol InteractionBarConfiguration {
    var savedInteractionBar: InteractionBarActions? { get set }
    var savedPinnedInteractionBarItems: Set<InteractionBarItem>? { get set }

    func widgetPickerPage(_ configuration: Binding<Self>) -> SettingsPage

    static var availableActions: ActionSeedSections { get }
    static var defaultInteractionBar: InteractionBarActions { get }

    static var defaultPinnedInteractionBarItems: Set<InteractionBarItem> { get }
}

extension InteractionBarConfiguration {
    var interactionBar: InteractionBarActions {
        get {
            savedInteractionBar ?? Self.defaultInteractionBar
        }
        set {
            savedInteractionBar = newValue
        }
    }

    var pinnedInteractionBarItems: Set<InteractionBarItem> {
        get {
            savedPinnedInteractionBarItems ?? Self.defaultPinnedInteractionBarItems
        }
        set {
            savedPinnedInteractionBarItems = newValue
        }
    }

    mutating func applyInteractionBar<Configuration: InteractionBarConfiguration>(other: Configuration) {
        let interactionBar = other.savedInteractionBar ?? Configuration.defaultInteractionBar
        self.savedInteractionBar = interactionBar.filter(allowed: Self.availableActions.all)
    }

    static func allItems() -> [InteractionBarItem] {
        CounterType.allCases.map {
            .counter($0)
        } + availableActions.all.map {
            .action($0)
        }
    }
}
