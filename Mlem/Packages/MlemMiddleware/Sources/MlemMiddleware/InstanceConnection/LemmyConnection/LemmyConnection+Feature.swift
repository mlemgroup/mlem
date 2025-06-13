//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation

public extension LemmyConnection {
    func supports(_ feature: Feature) async throws -> Bool {
        try await supports(feature, version: version)
    }
    
    func supportsOrNil(_ feature: Feature) -> Bool? {
        if let fetchedVersion {
            return supports(feature, version: fetchedVersion)
        } else {
            return nil
        }
    }

    internal func supports(
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
        case .searchLocalPeople, .moderatorsCanViewVotes, .hidePosts, .fullyFeaturedReports:
            version >= .v0_19_4
        }
    }
}
