//
//  ApiPostAggregates.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// PostAggregates.ts
struct ApiPostAggregates: Codable {
    let postId: Int
    let comments: Int
    let score: Int
    let upvotes: Int
    let downvotes: Int
    let published: Date
    let newestCommentTime: String
    let id: Int?
    let newestCommentTimeNecro: String?
    let featuredCommunity: Bool?
    let featuredLocal: Bool?
    let hotRank: Int?
    let hotRankActive: Int?
}
