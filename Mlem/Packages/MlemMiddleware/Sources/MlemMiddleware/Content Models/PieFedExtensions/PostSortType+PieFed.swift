//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension PostSortType {
    var pieFedSortType: PieFedSortType? {
        switch self {
        case .active: .active
        case .hot: .hot
        case .new: .new
        case .old: nil
        case .mostComments: nil
        case .newComments: nil
        case .controversial: nil
        case .scaled: .scaled
        case let .top(range):
            range.pieFedSortType
        }
    }
}
