//
//  InboxItemFilter.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-12-04.
//

public enum InboxItemFilterType {
    case read, dedupe
}

class InboxItemFilter: MultiFilter<InboxNotification> {
    private var readFilter: ReadFilter<InboxNotification>
    private var dedupeFilter: InboxDedupeFilter<InboxNotification> = .init(context: .none())
    
    init(showRead: Bool) {
        self.readFilter = .init(context: .none())
        if showRead {
            readFilter.active = false
        }
    }

    override func allFilters() -> [FilterProviding<InboxNotification>] {
        [
            readFilter,
            dedupeFilter
        ]
    }
    
    override func getFilter(_ toGet: InboxItemFilterType) -> FilterProviding<InboxNotification> {
        switch toGet {
        case .read: readFilter
        case .dedupe: dedupeFilter
        }
    }
}
