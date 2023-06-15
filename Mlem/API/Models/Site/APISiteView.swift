//
//  APISiteView.swift
//  Mlem
//
//  Created by Jonathan de Jong on 12/06/2023.
//

import Foundation

// lemmy_db_views::structs::SiteView
struct APISiteView: Decodable {
    let site: APISite
    let localSite: APILocalSite
    let localSiteRateLimit: APILocalSiteRateLimit
    let counts: APISiteAggregates
}
