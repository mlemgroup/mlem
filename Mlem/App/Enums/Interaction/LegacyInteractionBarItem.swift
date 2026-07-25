//
//  LegacyInteractionBarItem.swift
//  Mlem
//
//  Created by Sjmarf on 2026-07-25.
//

// Used to convert Mlem 2.5 -> 2.6

import Actions
import Foundation

enum LegacyInteractionBarItem<ActionType: LegacyActionTypeProviding>: Codable, Hashable {
    case action(ActionType)
    case counter(CounterType)
    
    func toInteractionBarItem() -> InteractionBarItem {
        switch self {
        case let .action(action):
            .action(action.actionSeed)
        case let .counter(counter):
            .counter(counter)
        }
    }
}

protocol LegacyActionTypeProviding: Codable, Hashable {
    var actionSeed: ActionSeed { get }
}
