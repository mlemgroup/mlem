//
//  InteractionConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 15/08/2024.
//

import Actions
import Foundation
import Icons
import MlemMiddleware
import SwiftUI

protocol InteractionBarConfiguration: Codable, SwipeActionConfiguration, ContextMenuConfiguration {
    associatedtype ActionType: ActionTypeProviding
    
    typealias Item = InteractionConfigurationItem<ActionType>

    static var availableActions: ActionSeedSections { get }
    
    init()
}

enum InteractionConfigurationItem<ActionType: ActionTypeProviding>: Codable, Hashable {
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

protocol ActionTypeProviding: Codable, Hashable {
    var actionSeed: ActionSeed { get }
}

struct MockReadoutAppearance {
    let icon: Icon
    let label: String
}
