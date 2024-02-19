//
//  APISiteAggregates.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/SiteAggregates.ts
struct APISiteAggregates: Codable {
    let site_id: Int
    let users: Int
    let posts: Int
    let comments: Int
    let communities: Int
    let users_active_day: Int
    let users_active_week: Int
    let users_active_month: Int
    let users_active_half_year: Int
}
