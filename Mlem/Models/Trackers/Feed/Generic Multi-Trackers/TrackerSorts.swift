//
//  TrackerSorts.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//

import Foundation

enum TrackerSortType {
    case published
}

enum TrackerSortVal {
    case published(Date)
    
    func shouldSortBefore(_ other: TrackerSortVal?) -> Bool {
        guard let other else {
            return true
        }
        
        switch self {
        case let .published(selfDate):
            switch other {
            case let .published(otherDate):
                return selfDate >= otherDate
            }
        }
    }
}
