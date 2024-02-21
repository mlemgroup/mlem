//
//  ApiSiteAggregates.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// SiteAggregates.ts
struct ApiSiteAggregates: Codable {
    let siteId: Int
    let users: Int
    let posts: Int
    let comments: Int
    let communities: Int
    let usersActiveDay: Int
    let usersActiveWeek: Int
    let usersActiveMonth: Int
    let usersActiveHalfYear: Int
    let id: Int?
}
