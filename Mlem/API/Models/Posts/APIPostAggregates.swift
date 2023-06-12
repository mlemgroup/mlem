//
//  APIPostAggregates.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::aggregates::structs::PostAggregates
struct APIPostAggregates: Decodable {
    let id: Int
    let postId: Int
    let comments: Int
    var score: Int
    let upvotes: Int
    let downvotes: Int
    let published: Date
    let newestCommentTime: Date
    let newestCommentTimeNecro: Date
    let featuredCommunity: Bool
    let featuredLocal: Bool
}
