//
//  APISiteView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/SiteView.ts
struct APISiteView: Codable {
    let site: APISite
    let localSite: APILocalSite
    let localSiteRateLimit: APILocalSiteRateLimit
    let counts: APISiteAggregates
}
