//
//  InteractionBarItem.swift
//  Mlem
//
//  Created by Sjmarf on 2026-07-24.
//

import Actions
import Foundation

enum InteractionBarItem: Encodable, Equatable {
    case action(ActionSeed)
    case counter(CounterType)

    func matchesActionSeedList(_ seeds: Set<String>) -> Bool {
        switch self {
        case let .action(seed): seeds.contains(seed.key)
        case .counter: true
        }
    }
}
