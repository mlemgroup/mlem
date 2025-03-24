//
//  ModMailItemFilter.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-01-31.
//

public enum ModMailItemFilterType {
    case read, dedupe
}

class ModMailItemFilter: MultiFilter<ModMailItem> {
    private var readFilter: ReadFilter<ModMailItem>
    private var dedupeFilter: InboxDedupeFilter<ModMailItem> = .init()
    
    init(showRead: Bool) {
        self.readFilter = .init()
        if showRead {
            readFilter.active = false
        }
    }

    override func allFilters() -> [any FilterProviding<ModMailItem>] {
        [
            readFilter,
            dedupeFilter
        ]
    }
    
    override func getFilter(_ toGet: ModMailItemFilterType) -> any FilterProviding<ModMailItem> {
        switch toGet {
        case .read: readFilter
        case .dedupe: dedupeFilter
        }
    }
}
