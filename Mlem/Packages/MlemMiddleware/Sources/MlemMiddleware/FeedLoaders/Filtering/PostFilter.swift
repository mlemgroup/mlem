//
//  PostFilter.swift
//
//
//  Created by Eric Andrews on 2024-05-31.
//

import Foundation

public enum PostFilterType {
    case read, dedupe, keyword
}

class PostFilter: MultiFilter<Post2> {
    private var readFilter: ReadFilter<Post2>
    private var dedupeFilter: DedupeFilter<Post2> = .init()
    private var keywordFilter: PostKeywordFilter
    
    init(showRead: Bool, context: FilterContext) {
        self.keywordFilter = .init(context: context)
        self.readFilter = .init()
        if showRead {
            readFilter.active = false
        }
    }

    override func allFilters() -> [any FilterProviding<Post2>] {
        [
            readFilter,
            dedupeFilter,
            keywordFilter
        ]
    }
    
    override func getFilter(_ toGet: PostFilterType) -> any FilterProviding<Post2> {
        switch toGet {
        case .read: readFilter
        case .dedupe: dedupeFilter
        case .keyword: keywordFilter
        }
    }
    
    // MARK: Custom Behavior
    
    func updateContext(to context: FilterContext) {
        keywordFilter.updateFilterContext(to: context)
    }
}
