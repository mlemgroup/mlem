//
//  APICommunityAggregates.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/CommunityAggregates.ts
struct APICommunityAggregates: Codable {
    let communityId: Int
    let subscribers: Int
    let posts: Int
    let comments: Int
    let published: Date
    let usersActiveDay: Int
    let usersActiveWeek: Int
    let usersActiveMonth: Int
    let usersActiveHalfYear: Int
}
