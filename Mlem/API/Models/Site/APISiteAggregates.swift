//
//  APISiteAggregates.swift
//  Mlem
//
//  Created by Jonathan de Jong on 12/06/2023.
//

import Foundation

// lemmy_db_schema::aggregates::structs::SiteAggregates
struct APISiteAggregates: Decodable {
    let id: Int
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
