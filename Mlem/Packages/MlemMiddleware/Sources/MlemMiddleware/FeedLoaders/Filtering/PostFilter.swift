//
//  PostFilter.swift
//
//
//  Created by Eric Andrews on 2024-05-31.
//

import Foundation

public enum PostFilterType {
    case read, dedupe, keyword, literal
}

class PostFilter: MultiFilter<Post> {
    private var readFilter: UnifiedReadFilter<Post>
    private var dedupeFilter: DedupeFilter<Post> = .init(context: .none())
    private var keywordFilter: PostKeywordFilter
    private var literalFilter: PostLiteralFilter
    
    init(showRead: Bool, context: FilterContext) {
        self.keywordFilter = .init(context: context)
        self.literalFilter = .init(context: context)
        self.readFilter = .init(context: .none())
        if showRead {
            readFilter.active = false
        }
    }

    override func allFilters() -> [FilterProviding<Post>] {
        [
            readFilter,
            dedupeFilter,
            keywordFilter,
            literalFilter
        ]
    }
    
    override func getFilter(_ toGet: PostFilterType) -> FilterProviding<Post> {
        switch toGet {
        case .read: readFilter
        case .dedupe: dedupeFilter
        case .keyword: keywordFilter
        case .literal: literalFilter
        }
    }
    
    // MARK: Custom Behavior
    
    func updateContext(to context: FilterContext) {
        keywordFilter.updateFilterContext(to: context)
        literalFilter.updateFilterContext(to: context)
    }
}
