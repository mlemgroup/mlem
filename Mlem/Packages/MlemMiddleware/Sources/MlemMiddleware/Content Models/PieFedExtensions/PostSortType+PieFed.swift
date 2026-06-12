//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension PostSortType {
    var pieFedSearchSortType: PieFedSearchSortType? {
        switch self {
        case .active: nil
        case .hot: .hot
        case .new: .new
        case .old: .old
        case .mostComments: nil
        case .newComments: .active // This is intentional
        case .controversial: nil
        case .scaled: .scaled
        case let .top(range):
            range.pieFedSearchSortType
        }
    }

    var pieFedSortType: PieFedSortType? {
        switch self {
        case .active: nil
        case .hot: .hot
        case .new: .new
        case .old: .old
        case .mostComments: nil
        case .newComments: .active // This is intentional
        case .controversial: nil
        case .scaled: .scaled
        case let .top(range):
            range.pieFedSortType
        }
    }
}
