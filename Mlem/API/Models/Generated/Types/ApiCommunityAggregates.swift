//
//  ApiCommunityAggregates.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-25
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// CommunityAggregates.ts
struct ApiCommunityAggregates: Codable {
    let id: Int?
    let communityId: Int
    let subscribers: Int
    let posts: Int
    let comments: Int
    let published: Date
    let usersActiveDay: Int
    let usersActiveWeek: Int
    let usersActiveMonth: Int
    let usersActiveHalfYear: Int
    let hotRank: Int?
    let subscribersLocal: Int?
}
