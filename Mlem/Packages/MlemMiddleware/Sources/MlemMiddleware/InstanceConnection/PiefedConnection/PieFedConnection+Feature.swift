//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation

public extension PieFedConnection {
    func supports(_ feature: Feature) async throws -> Bool {
        try await Self.supports(feature, version: version)
    }
    
    func supports(_ feature: Feature, defaultValue: Bool) -> Bool {
        if let fetchedVersion {
            return Self.supports(feature, version: fetchedVersion)
        } else {
            return defaultValue
        }
    }

    static func supports(
        _ feature: Feature,
        version: SiteVersion
    ) -> Bool {
        switch feature {
        case let .postSortType(sort):
            version >= sort.minimumVersion
        case let .commentSortType(sort):
            version >= sort.minimumVersion
        case let .communitySortType(sort):
            version >= sort.minimumVersion
        case let .personSortType(sort):
            version >= sort.minimumVersion
        case let .sortTimeRange(timeRange):
            version >= timeRange.minimumVersion
        case let .listingType(listingType):
            listingType.pieFedListingType != nil
        case .userNotes, .searchLocalComments, .fetchLinkMetadata:
            version >= .v1_4_0
        case .moderatorSetNsfw, .toggleNotifications: true
        case .modlog:
            version >= .v1_6_10
        case .editDisplayName:
            // Support may have been added earlier, but I only tested this on 1.6.27
            version >= .v1_6_27
        default: false
        }
    }
}

private extension SiteVersion {
    static let v1_3_0: Self = .init("1.3.0")
    static let v1_4_0: Self = .init("1.4.0")
    static let v1_6_10: Self = .init("1.6.10")
    static let v1_6_27: Self = .init("1.6.27")
}

private extension PostSortType {
    var minimumVersion: SiteVersion {
        switch self {
        case .active: .infinity
        case .hot: .zero
        case .new: .zero
        case .old: .zero
        case .mostComments: .infinity
        case .newComments: .zero
        case .controversial: .infinity
        case .scaled: .zero
        case let .top(timeRange): timeRange.minimumVersion
        }
    }
}

private extension CommentSortType {
    var minimumVersion: SiteVersion {
        switch self {
        case .new: .zero
        case .old: .zero
        case .hot: .zero
        case .controversial: .v1_4_0
        case let .top(timeRange): timeRange == .allTime ? .zero : .infinity
        }
    }
}

private extension CommunitySortType {
    var minimumVersion: SiteVersion {
        switch self {
        case .new, .old, .postCount, .newPostsOrComments: .zero
        case .federationDate, .subscriberCount: .v1_6_27
        case .hot, .name, .commentCount,
             .activeUserCount,
             .localSubscriberCount: .infinity
        }
    }
}

private extension PersonSortType {
    var minimumVersion: SiteVersion {
        self.pieFedSearchSortType != nil ? .zero : .infinity
    }
}

private extension SortTimeRange {
    var minimumVersion: SiteVersion {
        switch self {
        case .allTime: .zero
        case let .limited(timeInterval): LegacySortTimeRangeLimit(timeInterval)?.minimumVersion ?? .infinity
        }
    }
}

private extension LegacySortTimeRangeLimit {
    var minimumVersion: SiteVersion {
        switch self {
        case .threeMonth, .sixMonth, .nineMonth, .year: .zero
        default: .zero
        }
    }
}
