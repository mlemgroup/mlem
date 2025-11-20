//
//  InboxDedupeFilter.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-02-01.
//

/// Filter that dedupes InboxIdentifiable items by inboxId
class InboxDedupeFilter<FilterTarget: InboxIdentifiable>: FilterProviding<FilterTarget> {
    private var seen: Set<Int> = .init()
    
    override func reset(with targets: [FilterTarget]?) -> [FilterTarget] {
        numFiltered = 0
        seen = .init()
        if let targets { return filter(targets) }
        return .init()
    }
    
    override public func shouldPassFilter(_ item: FilterTarget) -> Bool {
        seen.insert(item.inboxId).inserted
    }
}
