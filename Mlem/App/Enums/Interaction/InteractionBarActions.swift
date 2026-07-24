//
//  InteractionBarActions.swift
//  Mlem
//
//  Created by Sjmarf on 2026-07-24.
//

import Actions
import Foundation

struct InteractionBarActions {
    var leading: [InteractionBarItem]
    var trailing: [InteractionBarItem]
    var readouts: [ReadoutType]

    func filter(allowed seeds: [ActionSeed]) -> InteractionBarActions {
        let keys = Set(seeds.lazy.map(\.key))
        return .init(
            leading: leading.filter { $0.matchesActionSeedList(keys) },
            trailing: trailing.filter { $0.matchesActionSeedList(keys) },
            readouts: readouts
        )
    }
}

enum InteractionBarItem {
    case action(ActionSeed)
    case counter(CounterType)

    fileprivate func matchesActionSeedList(_ seeds: Set<String>) -> Bool {
        switch self {
        case let .action(seed): seeds.contains(seed.key)
        case .counter: true
        }
    }
}
