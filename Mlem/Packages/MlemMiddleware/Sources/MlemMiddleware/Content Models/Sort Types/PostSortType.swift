//
//  PostSortTimeRange.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-25.
//

import Foundation

public enum PostSortType: Hashable, Sendable {
    case active
    case hot
    case new
    case old
    case mostComments
    case newComments
    case controversial
    case scaled
    
    /// From 1.0.0 onwards, any time interval is supported.
    /// Before 1.0.0, there is a discrete list of supported time intervals,
    /// represented by the ``LegacySortTimeRange`` type.
    case top(SortTimeRange)
    
    public var isTop: Bool {
        switch self {
        case .top: true
        default: false
        }
    }
    
    public static var nonTopCases: [Self] = [
        .hot,
        .scaled,
        .active,
        .new,
        .old,
        .controversial,
        .newComments,
        .mostComments
    ]
    
    public static var legacyTopCases: [Self] = SortTimeRange.legacyCases.map { .top($0) }
    
    public static var legacyCases: [Self] = nonTopCases + legacyTopCases
    
    public init(_ legacyApiSortType: LemmySortType) {
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
    public var legacyApiSortType: LemmySortType? {
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
    
    public var apiSortType: LemmyPostSortType {
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
    public var apiSearchSortType: LemmySearchSortType? {
        switch self {
        case .new: .new
        case .old: .old
        case .top: .top
        default: nil
        }
    }
    
    public var timeRange: SortTimeRange? {
        switch self {
        case let .top(timeRange): timeRange
        default: nil
        }
    }
    
    // This should only be used internally within ApiClient
    var timeRangeSeconds: Int? { timeRange?.timeRangeSeconds }
    
    public var minimumVersion: SiteVersion {
        switch self {
        case let .top(timeRange): timeRange.minimumVersion
        default: .zero
        }
    }
}
