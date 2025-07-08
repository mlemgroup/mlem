//
//  FeedLoaderSort.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//
import Foundation

public enum FeedLoaderSort: Comparable {
    case new(Date)
    
    public enum SortType {
        case new
    }
}

public extension FeedLoaderSort {
    var sortType: FeedLoaderSort.SortType {
        switch self {
        case .new: .new
        }
    }
    
    var apiType: LemmySortType {
        switch self {
        case .new: .new
        }
    }
    
    func typeEquals(lhs: FeedLoaderSort, rhs: FeedLoaderSort) -> Bool {
        lhs.sortType == rhs.sortType
    }
    
    /// Compares two FeedLoaderSorts. Returns true if rhs should be sorted after lhs. Assumes that higher items should be sorted first; thus for some sorts (e.g., "old"), the result will be "flipped," since _lower_ dates should be sorted ahead of higher ones.
    static func < (lhs: FeedLoaderSort, rhs: FeedLoaderSort) -> Bool {
        guard lhs.sortType == rhs.sortType else {
            assertionFailure("Compare called on TrackerSorts with different types")
            return true
        }
        
        switch lhs {
        case let .new(lhsDate):
            switch rhs {
            case let .new(rhsDate):
                return lhsDate < rhsDate
            }
        }
    }
}
