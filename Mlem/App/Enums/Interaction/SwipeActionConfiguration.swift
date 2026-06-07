//
//  SwipeActionConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-15.
//

import Actions
import Foundation

protocol SwipeActionConfiguration {
    var savedSwipes: ActionSeedSwipeConfiguration? { get set }

    static var availableActions: ActionSeedSections { get }
    static var defaultSwipes: ActionSeedSwipeConfiguration { get }
}

extension SwipeActionConfiguration {
    var swipes: ActionSeedSwipeConfiguration {
        get {
            savedSwipes ?? Self.defaultSwipes
        }
        set {
            savedSwipes = newValue
        }
    }

    mutating func applySwipes<Configuration: SwipeActionConfiguration>(other: Configuration) {
        let swipes = other.savedSwipes ?? Configuration.defaultSwipes
        self.savedSwipes = swipes.filter(allowed: Self.availableActions.all)
    }
}
