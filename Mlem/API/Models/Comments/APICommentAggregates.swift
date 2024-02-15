//
//  APICommentAggregates.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::aggregates::structs::CommentAggregates
struct APICommentAggregates: Decodable, APIContentAggregatesProtocol {
    internal init(
        id: Int? = nil,
        commentId: Int = 0,
        score: Int = 8,
        upvotes: Int = 9,
        downvotes: Int = 1,
        published: Date = .mock,
        childCount: Int = 10
    ) {
        self.id = id
        self.commentId = commentId
        self.score = score
        self.upvotes = upvotes
        self.downvotes = downvotes
        self.published = published
        self.childCount = childCount
    }
    
    let id: Int? // TODO: 0.18 Deprecation remove this field
    let commentId: Int
    let score: Int
    let upvotes: Int
    let downvotes: Int
    let published: Date
    let childCount: Int
    
    var comments: Int { childCount }
}

extension APICommentAggregates: Mockable {
    static var mock: APICommentAggregates { .init() }
}
