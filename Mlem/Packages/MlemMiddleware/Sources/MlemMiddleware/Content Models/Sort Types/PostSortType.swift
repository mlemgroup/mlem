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
    /// Added in 0.19.0
    case controversial
    /// Added in 0.19.0
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
    
    public init(_ legacyApiSortType: ApiSortType) {
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
    
    /// Returns `nil` if the `PostSortType` is a value that cannot be converted to an `ApiSortType`.
    public var legacyApiSortType: ApiSortType? {
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
    
    public var apiSortType: ApiPostSortType {
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
    
    /// Returns `nil` if the `PostSortType` is a value that cannot be converted to an `ApiSearchSortType`.
    public var apiSearchSortType: ApiSearchSortType? {
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
        case .controversial, .scaled: .v0_19_0
        case let .top(timeRange): timeRange.minimumVersion
        default: .zero
        }
    }
}
