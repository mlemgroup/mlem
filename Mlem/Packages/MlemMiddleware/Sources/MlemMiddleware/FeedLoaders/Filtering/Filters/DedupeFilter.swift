//
//  PostDedupeFilter.swift
//
//
//  Created by Eric Andrews on 2024-05-31.
//

import Foundation

/// Filter that dedupes ActorIdentifiable items by actorId
class DedupeFilter<FilterTarget: ActorIdentifiable>: FilterProviding<FilterTarget> {
    private var seen: Set<ActorIdentifier> = .init()
    
    override func reset(with targets: [FilterTarget]?) -> [FilterTarget] {
        numFiltered = 0
        seen = .init()
        if let targets { return filter(targets) }
        return .init()
    }
    
    override public func shouldPassFilter(_ item: FilterTarget) -> Bool {
        seen.insert(item.actorId).inserted
    }
}
