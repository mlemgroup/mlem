//
//  SearchSortTimeRange.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-28.
//

import Foundation

// In the v3 API, it was possible to search for posts using any
// of the regular post sorts ("Hot", "Active" etc). This was
// intentionally removed in v4.
// https://github.com/LemmyNet/lemmy/issues/5401

public enum SearchSortType: Hashable, Sendable {
    case new
    case old
    
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
    
    public static var nonTopCases: [Self] = [.new, .old]
    public static var legacyTopCases: [Self] = SortTimeRange.legacyCases.map { .top($0) }
    public static var legacyCases: [Self] = nonTopCases + legacyTopCases
    public static var legacyPersonCases: [Self] = nonTopCases + [.top(.allTime)]
    
    public init?(_ legacyApiSortType: ApiSortType) {
        switch legacyApiSortType {
        case .new:
            self = .new
        case .old:
            self = .old
        default:
            if let timeRange = SortTimeRange(legacyApiSortType) {
                self = .top(timeRange)
            } else {
                return nil
            }
        }
    }
    
    /// Returns `nil` if the `SearchSortType` is a value that cannot be converted to an `ApiSortType`.
    public var legacyApiSortType: ApiSortType? {
        switch self {
        case .new: .new
        case .old: .old
        case let .top(timeRange): timeRange.legacyApiSortType
        }
    }
    
    /// Returns `nil` if the `SearchSortType` is a value that cannot be converted to an `ApiSearchSortType`.
    public var apiSortType: ApiSearchSortType? {
        switch self {
        case .new: .new
        case .old: .old
        case .top: .top
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
