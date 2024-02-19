//
//  APIPostAggregates.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/PostAggregates.ts
struct APIPostAggregates: Codable {
    let postId: Int
    let comments: Int
    let score: Int
    let upvotes: Int
    let downvotes: Int
    let published: Date
    let newestCommentTime: String
}
