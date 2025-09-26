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
        case let .searchSortType(sort):
            version >= sort.minimumVersion
        case let .sortTimeRange(timeRange):
            version >= timeRange.minimumVersion
        case let .listingType(listingType):
            listingType.pieFedListingType != nil
        case .viewCommunityActiveUsers, .viewMentionsAndPrivateMessages, .editAndDeletePrivateMessages, .autoMarkPostReadOnInteract:
            version >= .v1_1_0
        case .editProfile, .viewVotes, .undeletePrivateMessages:
            version >= .v1_2_0
        default: false
        }
    }
}

private extension SiteVersion {
    static let v1_0_0: Self = .init("1.0.0")
    static let v1_1_0: Self = .init("1.1.0")
    static let v1_2_0: Self = .init("1.2.0")
}

private extension PostSortType {
    var minimumVersion: SiteVersion {
        switch self {
        case .active: .infinity
        case .hot: .zero
        case .new: .zero
        case .old: .infinity
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
        case .controversial: .infinity
        case let .top(timeRange): timeRange == .allTime ? .zero : .infinity
        }
    }
}

private extension SearchSortType {
    var minimumVersion: SiteVersion {
        switch self {
        case .new: .zero
        case .old: .infinity
        case let .top(timeRange): timeRange.minimumVersion
        }
    }
}

private extension SortTimeRange {
    var minimumVersion: SiteVersion {
        switch self {
        case .allTime: .v1_1_0
        case let .limited(timeInterval): LegacySortTimeRangeLimit(timeInterval)?.minimumVersion ?? .infinity
        }
    }
}

private extension LegacySortTimeRangeLimit {
    var minimumVersion: SiteVersion {
        switch self {
        case .threeMonth, .sixMonth, .nineMonth, .year: .v1_1_0
        default: .zero
        }
    }
}
