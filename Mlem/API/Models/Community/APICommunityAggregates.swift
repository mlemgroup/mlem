//
//  APICommunityAggregates.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::aggregates::structs::CommunityAggregates
struct APICommunityAggregates: Decodable {
    let id: Int? // TODO: 0.18 Deprecation remove this field
    let communityId: Int
    let subscribers: Int
    let subscribersLocal: Int?
    let posts: Int
    let comments: Int
    let published: Date
    let usersActiveDay: Int
    let usersActiveWeek: Int
    let usersActiveMonth: Int
    let usersActiveHalfYear: Int
}
