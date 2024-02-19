//
//  APISiteView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/SiteView.ts
struct APISiteView: Codable {
    let site: APISite
    let local_site: APILocalSite
    let local_site_rate_limit: APILocalSiteRateLimit
    let counts: APISiteAggregates
}
