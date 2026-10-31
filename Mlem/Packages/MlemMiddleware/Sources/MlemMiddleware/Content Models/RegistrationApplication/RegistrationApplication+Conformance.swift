//
//  RegistrationApplication+Conformance.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-10-31.
//

// MARK: CacheIdentifiable

public extension RegistrationApplication {
    var cacheId: Int { id }
}

// MARK: ContentIdentifiable

public extension RegistrationApplication {
    static var modelTypeId: ContentType { .registrationApplication }
}

// MARK: FeedLoadable

public extension RegistrationApplication {
    typealias FilterType = ModMailItemFilterType
    
    func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort {
        switch sortType {
        case .new: .new(created)
        }
    }
}
