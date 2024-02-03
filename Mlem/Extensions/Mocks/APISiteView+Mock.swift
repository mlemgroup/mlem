//
//  APISiteView+Mock.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation

extension APISiteView {
    static func mock(
        site: APISite = .mock(),
        localSite: APILocalSite = .mock(),
        localSiteRateLimit: APILocalSiteRateLimit = .mock(),
        counts: APISiteAggregates = .mock()
    ) -> APISiteView {
        .init(
            site: site,
            localSite: localSite,
            localSiteRateLimit: localSiteRateLimit,
            counts: counts
        )
    }
}
