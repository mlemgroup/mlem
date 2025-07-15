//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

// This is reluncantly public because Mlem uses it; this should really be `internal`
public extension PostSortType {
    init(_ legacyApiSortType: LemmySortType) {
        switch legacyApiSortType {
        case .active: self = .active
        case .hot: self = .hot
        case .new: self = .new
        case .old: self = .old
        case .mostComments: self = .mostComments
        case .newComments: self = .newComments
        case .controversial: self = .controversial
        case .scaled: self = .scaled
        default:
            if let timeRange = SortTimeRange(legacyApiSortType) {
                self = .top(timeRange)
            } else {
                assertionFailure()
                self = .top(.allTime)
            }
        }
    }
    
    /// Returns `nil` if the `PostSortType` is a value that cannot be converted to an `LemmySortType`.
    var legacyApiSortType: LemmySortType? {
        switch self {
        case .active: .active
        case .hot: .hot
        case .new: .new
        case .old: .old
        case .mostComments: .mostComments
        case .newComments: .newComments
        case .controversial: .controversial
        case .scaled: .scaled
        case let .top(timeRange): timeRange.legacyApiSortType
        }
    }
    
    var apiSortType: LemmyPostSortType {
        switch self {
        case .active: .active
        case .hot: .hot
        case .new: .new
        case .old: .old
        case .mostComments: .mostComments
        case .newComments: .newComments
        case .controversial: .controversial
        case .scaled: .scaled
        case .top: .top
        }
    }
    
    /// Returns `nil` if the `PostSortType` is a value that cannot be converted to an `LemmySearchSortType`.
    var apiSearchSortType: LemmySearchSortType? {
        switch self {
        case .new: .new
        case .old: .old
        case .top: .top
        default: nil
        }
    }
}
