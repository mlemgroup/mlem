//
//  APIPostAggregates.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::aggregates::structs::PostAggregates
struct APIPostAggregates: Decodable, APIContentAggregatesProtocol {
    internal init(
        id: Int? = nil,
        postId: Int = 0,
        comments: Int = 40,
        score: Int = 105,
        upvotes: Int = 109,
        downvotes: Int = 4,
        published: Date = .mock,
        newestCommentTime: Date? = nil,
        newestCommentTimeNecro: Date? = nil,
        featuredCommunity: Bool? = nil,
        featuredLocal: Bool? = nil
    ) {
        self.id = id
        self.postId = postId
        self.comments = comments
        self.score = score
        self.upvotes = upvotes
        self.downvotes = downvotes
        self.published = published
        self.newestCommentTime = newestCommentTime
        self.newestCommentTimeNecro = newestCommentTimeNecro
        self.featuredCommunity = featuredCommunity
        self.featuredLocal = featuredLocal
    }
    
    let id: Int? // TODO: 0.18 Deprecation remove this field
    let postId: Int
    let comments: Int
    var score: Int
    let upvotes: Int
    let downvotes: Int
    let published: Date
    // TODO: 0.18 Deprecation remove these fields
    let newestCommentTime: Date?
    let newestCommentTimeNecro: Date?
    let featuredCommunity: Bool?
    let featuredLocal: Bool?
}

extension APIPostAggregates: Mockable {
    static var mock: APIPostAggregates { .init() }
}
