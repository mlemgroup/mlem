//
//  UnifiedPostFilter.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-05.
//

// TODO: NOW implement

class UnifiedPostFilter: MultiFilter<UnifiedPostModel> {
//    private var readFilter: ReadFilter<UnifiedPostModel>
//    private var dedupeFilter: DedupeFilter<UnifiedPostModel> = .init(context: .none())
//    private var keywordFilter: PostKeywordFilter
//    private var literalFilter: PostLiteralFilter
    
    init(showRead: Bool, context: FilterContext) {
//        self.keywordFilter = .init(context: context)
//        self.literalFilter = .init(context: context)
//        self.readFilter = .init(context: .none())
//        if showRead {
//            readFilter.active = false
//        }
    }

    override func allFilters() -> [FilterProviding<UnifiedPostModel>] {
        [
//            readFilter,
//            dedupeFilter,
//            keywordFilter,
//            literalFilter
        ]
    }
    
//    override func getFilter(_ toGet: PostFilterType) -> FilterProviding<UnifiedPostModel> {
//        switch toGet {
//        case .read: readFilter
//        case .dedupe: dedupeFilter
//        case .keyword: keywordFilter
//        case .literal: literalFilter
//        }
//    }
    
    // MARK: Custom Behavior
    
    func updateContext(to context: FilterContext) {
//        keywordFilter.updateFilterContext(to: context)
//        literalFilter.updateFilterContext(to: context)
    }
}
