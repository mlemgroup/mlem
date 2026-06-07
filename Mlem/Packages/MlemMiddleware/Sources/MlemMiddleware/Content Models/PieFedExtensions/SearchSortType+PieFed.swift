//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension SearchSortType {
    var pieFedSortType: PieFedSearchSortType? {
        switch self {
        case .new: .new
        case .old: nil
        case let .top(range):
            range.pieFedSearchSortType
        }
    }
}
