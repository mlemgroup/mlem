//
//  ActionSeedSwipeConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-04.
//

import Actions
import Foundation

struct ActionSeedSwipeConfiguration: Encodable, Equatable {
    var leading: [ActionSeed]   
    var trailing: [ActionSeed]

    enum CodingKeys: CodingKey {
        case leading, trailing
    }

    func filter(allowed seeds: [ActionSeed]) -> ActionSeedSwipeConfiguration {
        let keys = Set(seeds.lazy.map(\.key))
        return .init(
            leading: leading.filter { keys.contains($0.key) },
            trailing: trailing.filter { keys.contains($0.key) }
        )
    }
}

extension ActionSeedSwipeConfiguration {
    init(from container: KeyedDecodingContainer<CodingKeys>, availableActions: [ActionSeed]) throws {
        let leading = try container.decode([String].self, forKey: .leading) 
        self.leading = leading.compactMap { key in availableActions.first(where: {$0.key == key}) }
        let trailing = try container.decode([String].self, forKey: .trailing) 
        self.trailing = trailing.compactMap { key in availableActions.first(where: {$0.key == key}) }
    }
}
