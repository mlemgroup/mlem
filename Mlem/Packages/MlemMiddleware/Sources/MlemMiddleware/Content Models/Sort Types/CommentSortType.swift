//
//  CommentSortType.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-03-04.
//

import SwiftUI

public enum CommentSortType: Hashable, Sendable {
    case new
    case old
    case hot
    case controversial
    
    /// From 1.0.0 onwards, any time interval is supported.
    /// Before 1.0.0, only `.allTime` is supported.
    case top(SortTimeRange)
    
    public var isTop: Bool {
        switch self {
        case .top: true
        default: false
        }
    }
    
    public static var nonTopCases: [Self] = [
        .hot,
        .new,
        .old,
        .controversial
    ]
    
    public static var legacyCases: [Self] = nonTopCases + [.top(.allTime)]
    
    public var timeRange: SortTimeRange? {
        switch self {
        case let .top(timeRange): timeRange
        default: nil
        }
    }
    
    // This should only be used internally within ApiClient
    var timeRangeSeconds: Int? { timeRange?.timeRangeSeconds }
}
