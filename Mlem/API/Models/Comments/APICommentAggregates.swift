//
//  APICommentAggregates.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::aggregates::structs::CommentAggregates
struct APICommentAggregates: Decodable {
    let id: Int
    let commentId: Int
    let score: Int
    let upvotes: Int
    let downvotes: Int
    let published: Date
    let childCount: Int
}
