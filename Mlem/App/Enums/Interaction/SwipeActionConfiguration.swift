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
    var swipes: ActionSeedSwipeConfiguration { get set }

    static var availableActions: ActionSeedSections { get }
    static var defaultSwipes: ActionSeedSwipeConfiguration { get }
}
