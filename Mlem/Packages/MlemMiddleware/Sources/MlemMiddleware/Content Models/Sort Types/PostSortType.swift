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
    
    public var timeRange: SortTimeRange? {
        switch self {
        case let .top(timeRange): timeRange
        default: nil
        }
    }
    
    // This should only be used internally within ApiClient
    var timeRangeSeconds: Int? { timeRange?.timeRangeSeconds }
}
