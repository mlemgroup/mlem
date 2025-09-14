//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation

public extension LemmyConnection {
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
            version >= listingType.minimumVersion
        case .searchLocalCommunities, .viewInstanceSettings, .viewInstanceCreationDate, .modlog,
             .logIn, .signUp, .viewCommunityActiveUsers, .commentTreeSortedByDepth, .uploadImages,
             .editAccountSettings, .viewMentionsAndPrivateMessages, .viewReports, .editAndDeletePrivateMessages,
             .reportPrivateMessages, .viewVotes, .purgeContent, .removeCommunity, .banFromInstance,
             .banFromCommunity, .editModeratorList, .commentSearch, .undeletePrivateMessages, .searchLocalPeople,
             .hidePosts, .editDisplayName, .editProfile, .autoMarkPostReadOnInteract:
            true
        }
    }
}

private extension SiteVersion {
    static let v0_19_0: Self = .init("0.19.0")
    static let v0_19_1: Self = .init("0.19.1")
    static let v0_19_2: Self = .init("0.19.2")
    static let v0_19_3: Self = .init("0.19.3")
    static let v0_19_4: Self = .init("0.19.4")
    static let v0_19_5: Self = .init("0.19.5")
    static let v0_19_6: Self = .init("0.19.6")
    static let v0_19_7: Self = .init("0.19.7")
    static let v0_19_8: Self = .init("0.19.8")
    static let v0_19_9: Self = .init("0.19.9")
    static let v0_19_10: Self = .init("0.19.10")
    static let v0_19_11: Self = .init("0.19.11")
    static let v0_19_12: Self = .init("0.19.12")
    static let v1_0_0: Self = .init("1.0.0")
}

private extension PostSortType {
    var minimumVersion: SiteVersion {
        switch self {
        case let .top(timeRange): timeRange.minimumVersion
        default: .zero
        }
    }
}

private extension CommentSortType {
    var minimumVersion: SiteVersion {
        switch self {
        case let .top(timeRange): timeRange == .allTime ? .zero : .v1_0_0
        default: .zero
        }
    }
}

private extension SearchSortType {
    var minimumVersion: SiteVersion {
        switch self {
        case let .top(timeRange): timeRange.minimumVersion
        default: .zero
        }
    }
}

private extension SortTimeRange {
    var minimumVersion: SiteVersion {
        switch self {
        case .allTime: .zero
        case let .limited(timeInterval): LegacySortTimeRangeLimit(timeInterval)?.minimumVersion ?? .v1_0_0
        }
    }
}

private extension LegacySortTimeRangeLimit {
    var minimumVersion: SiteVersion { .zero }
}

private extension ListingType {
    var minimumVersion: SiteVersion {
        switch self {
        case .suggested: .v1_0_0
        case .popular: .infinity
        default: .zero
        }
    }
}
