//
//  APICommentAggregates.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/CommentAggregates.ts
struct APICommentAggregates: Codable {
    let commentId: Int
    let score: Int
    let upvotes: Int
    let downvotes: Int
    let published: Date
    let childCount: Int
}
