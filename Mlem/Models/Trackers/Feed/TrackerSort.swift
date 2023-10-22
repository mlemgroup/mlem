//
//  TrackerSort.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//
import Foundation

enum TrackerSortType {
    case published
}

enum TrackerSortVal: Comparable {
    case published(Date)
    
    static func typeEquals(lhs: TrackerSortVal, rhs: TrackerSortVal) -> Bool {
        switch lhs {
        case .published:
            switch rhs {
            case .published:
                return true
            }
        }
    }
    
    static func < (lhs: TrackerSortVal, rhs: TrackerSortVal) -> Bool {
        print("COMPARING")
        
        guard typeEquals(lhs: lhs, rhs: rhs) else {
            assertionFailure("Compare oncalled on trackersortvals with different types")
            return true
        }
        
        switch lhs {
        case let .published(lhsDate):
            switch rhs {
            case let .published(rhsDate):
                return lhsDate < rhsDate
            }
        }
    }

//    func shouldSortBefore(_ other: TrackerSortVal?) -> Bool {
//        guard let other else {
//            return true
//        }
//
//        switch self {
//        case let .published(selfDate):
//            switch other {
//            case let .published(otherDate):
//                return selfDate >= otherDate
//            }
//        }
//    }
}
