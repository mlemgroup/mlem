//
//  InteractionConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 15/08/2024.
//

import Foundation

protocol InteractionBarConfiguration {
    associatedtype ActionType: ActionTypeProviding
    associatedtype CounterType
    associatedtype ReadoutType
    
    typealias Item = InteractionConfigurationItem<ActionType, CounterType>
    
    var leading: [Item] { get }
    var trailing: [Item] { get }
    var readouts: [ReadoutType] { get }
    
    static var `default`: Self { get }
}

enum InteractionConfigurationItem<ActionType, CounterType> {
    case action(ActionType)
    case counter(CounterType)
}

protocol ActionTypeProviding {
    var appearance: ActionAppearance { get }
}
