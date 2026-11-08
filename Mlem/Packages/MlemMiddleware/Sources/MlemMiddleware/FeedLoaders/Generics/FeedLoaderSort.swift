//
//  FeedLoaderSort.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//
import Foundation

public enum FeedLoaderSort: Comparable {
    case new(Date)
    case top(score: Int)
    
    public enum SortType {
        case new, top
    }
}

public extension FeedLoaderSort {
    var sortType: FeedLoaderSort.SortType {
        switch self {
        case .new: .new
        case .top: .top
        }
    }
    
    var apiType: LemmySortType {
        switch self {
        case .new: .new
        case .top: .topAll
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
        
        return switch (lhs, rhs) {
        case let (.new(date1), .new(date2)):
            date1 < date2
        case let (.top(score1), .top(score2)):
            score1 < score2
        default:
            false
        }
    }
}
