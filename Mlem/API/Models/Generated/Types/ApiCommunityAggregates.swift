//
//  ApiCommunityAggregates.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// CommunityAggregates.ts
struct ApiCommunityAggregates: Codable {
    let communityId: Int
    let subscribers: Int
    let posts: Int
    let comments: Int
    let published: Date
    let usersActiveDay: Int
    let usersActiveWeek: Int
    let usersActiveMonth: Int
    let usersActiveHalfYear: Int
    let id: Int?
    let hotRank: Int?
}
