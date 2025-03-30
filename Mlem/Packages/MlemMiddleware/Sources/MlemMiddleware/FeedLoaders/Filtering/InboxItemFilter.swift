//
//  InboxItemFilter.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-12-04.
//

public enum InboxItemFilterType {
    case read, dedupe
}

class InboxItemFilter: MultiFilter<InboxItem> {
    private var readFilter: ReadFilter<InboxItem>
    private var dedupeFilter: InboxDedupeFilter<InboxItem> = .init()
    
    init(showRead: Bool) {
        self.readFilter = .init()
        if showRead {
            readFilter.active = false
        }
    }

    override func allFilters() -> [any FilterProviding<InboxItem>] {
        [
            readFilter,
            dedupeFilter
        ]
    }
    
    override func getFilter(_ toGet: InboxItemFilterType) -> any FilterProviding<InboxItem> {
        switch toGet {
        case .read: readFilter
        case .dedupe: dedupeFilter
        }
    }
}
