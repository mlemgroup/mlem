//
//  NewInteractionBarConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 2026-07-24.
//

import Actions
import Foundation

protocol NewInteractionBarConfiguration {
    var savedInteractionBar: InteractionBarActions? { get set }

    static var availableActions: ActionSeedSections { get }
    static var defaultInteractionBar: InteractionBarActions { get }
}

extension NewInteractionBarConfiguration {
    var interactionBar: InteractionBarActions {
        get {
            savedInteractionBar ?? Self.defaultInteractionBar
        }
        set {
            savedInteractionBar = newValue
        }
    }

    mutating func applyInteractionBar<Configuration: NewInteractionBarConfiguration>(other: Configuration) {
        let interactionBar = other.savedInteractionBar ?? Configuration.defaultInteractionBar
        self.savedInteractionBar = interactionBar.filter(allowed: Self.availableActions.all)
    }
}
