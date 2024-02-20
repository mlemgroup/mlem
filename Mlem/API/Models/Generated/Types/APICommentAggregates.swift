//
//  APICommentAggregates.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// CommentAggregates.ts
struct APICommentAggregates: Codable {
    let commentId: Int
    let score: Int
    let upvotes: Int
    let downvotes: Int
    let published: Date
    let childCount: Int
    let id: Int?
    let hotRank: Int?
}
