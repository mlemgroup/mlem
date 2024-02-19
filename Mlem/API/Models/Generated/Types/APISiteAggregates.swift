//
//  APISiteAggregates.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/SiteAggregates.ts
struct APISiteAggregates: Codable {
    let siteId: Int
    let users: Int
    let posts: Int
    let comments: Int
    let communities: Int
    let usersActiveDay: Int
    let usersActiveWeek: Int
    let usersActiveMonth: Int
    let usersActiveHalfYear: Int
}
