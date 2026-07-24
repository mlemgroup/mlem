//
//  InteractionBarActions.swift
//  Mlem
//
//  Created by Sjmarf on 2026-07-24.
//

import Actions
import Foundation
import MlemMiddleware

struct InteractionBarActions: Encodable, Equatable {
    var leading: [InteractionBarItem]
    var trailing: [InteractionBarItem]
    var readouts: [ReadoutType]

    enum CodingKeys: CodingKey {
        case leading, trailing, readouts
    }

    func filter(allowed seeds: [ActionSeed]) -> InteractionBarActions {
        let keys = Set(seeds.lazy.map(\.key))
        return .init(
            leading: leading.filter { $0.matchesActionSeedList(keys) },
            trailing: trailing.filter { $0.matchesActionSeedList(keys) },
            readouts: readouts
        )
    }

    var all: [InteractionBarItem] { leading + trailing }
    
    func associatedReadouts(context: any InteractableProviding) -> Set<ReadoutType> {
        all.reduce(into: Set<ReadoutType>()) { result, element in
            result.formUnion(element.associatedReadouts(context: context))
        }
    }
}

private enum RawInteractionBarItem: Decodable {
    case action(String)
    case counter(CounterType)
}

private extension InteractionBarItem {
    init?(raw: RawInteractionBarItem, availableActions: [ActionSeed]) {
        switch raw {
        case let .action(key):
            if let seed = availableActions.first(where: {$0.key == key}) {
                self = .action(seed)
            } else {
                return nil
            }
        case let .counter(counter):
            self = .counter(counter)
        }
    }
}

extension InteractionBarActions {
    init(from container: KeyedDecodingContainer<CodingKeys>, availableActions: [ActionSeed]) throws {
        let leading = try container.decode([RawInteractionBarItem].self, forKey: .leading) 
        self.leading = leading.compactMap { .init(raw: $0, availableActions: availableActions) }
        let trailing = try container.decode([RawInteractionBarItem].self, forKey: .trailing) 
        self.trailing = trailing.compactMap { .init(raw: $0, availableActions: availableActions) }
        self.readouts = try container.decode([ReadoutType].self, forKey: .readouts)
    }
}
