//
//  InteractionBarItem.swift
//  Mlem
//
//  Created by Sjmarf on 2026-07-24.
//

import Actions
import Foundation

enum InteractionBarItem: Encodable, Hashable {
    case action(ActionSeed)
    case counter(CounterType)

    func matchesActionSeedList(_ seeds: Set<String>) -> Bool {
        switch self {
        case let .action(seed): seeds.contains(seed.key)
        case .counter: true
        }
    }

    // This is used to determine when an interaction bar configuration is considered "full"
    var score: Int {
        switch self {
        case .action: 1
        case let .counter(counter):
            counter.appearance.leading == nil || counter.appearance.trailing == nil ? 2 : 3
        }
    }
}
