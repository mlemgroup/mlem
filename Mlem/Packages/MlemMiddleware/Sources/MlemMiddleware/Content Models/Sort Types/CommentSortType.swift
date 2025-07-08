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
    
    public init(_ apiSortType: LemmyCommentSortType) {
        self = switch apiSortType {
        case .hot: .hot
        case .top: .top(.allTime)
        case .new: .new
        case .old: .old
        case .controversial: .controversial
        }
    }
    
    public var apiSortType: LemmyCommentSortType {
        switch self {
        case .new: .new
        case .old: .old
        case .hot: .hot
        case .controversial: .controversial
        case .top: .top
        }
    }
    
    public var legacyApiSortType: LemmySortType {
        switch self {
        case .new: .new
        case .old: .old
        case .hot: .hot
        case .controversial: .controversial
        case .top: .topAll
        }
    }
    
    /// Returns `nil` if the `CommentSortType` is a value that cannot be converted to an `LemmySearchSortType`.
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
        case let .top(timeRange): timeRange == .allTime ? .zero : .v1_0_0
        default: .zero
        }
    }
}
