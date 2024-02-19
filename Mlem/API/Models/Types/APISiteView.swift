//
//  APISiteView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/SiteView.ts
struct APISiteView: Codable {
    let site: APISite
    let local_site: APILocalSite
    let local_site_rate_limit: APILocalSiteRateLimit
    let counts: APISiteAggregates

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
