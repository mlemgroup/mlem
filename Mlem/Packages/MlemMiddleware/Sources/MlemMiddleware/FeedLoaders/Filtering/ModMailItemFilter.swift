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
    private var dedupeFilter: InboxDedupeFilter<ModMailItem> = .init(context: .none())
    
    init(showRead: Bool) {
        self.readFilter = .init(context: .none())
        if showRead {
            readFilter.active = false
        }
    }

    override func allFilters() -> [FilterProviding<ModMailItem>] {
        [
            readFilter,
            dedupeFilter
        ]
    }
    
    override func getFilter(_ toGet: ModMailItemFilterType) -> FilterProviding<ModMailItem> {
        switch toGet {
        case .read: readFilter
        case .dedupe: dedupeFilter
        }
    }
}
