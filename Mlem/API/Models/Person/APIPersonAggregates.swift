//
//  APIPersonAggregates.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::aggregates::structs::PersonAggregates
struct APIPersonAggregates: Decodable {
    internal init(
        id: Int? = nil,
        personId: Int = 0,
        postCount: Int = 5,
        postScore: Int? = nil,
        commentCount: Int = 20,
        commentScore: Int? = nil
    ) {
        self.id = id
        self.personId = personId
        self.postCount = postCount
        self.postScore = postScore
        self.commentCount = commentCount
        self.commentScore = commentScore
    }
    
    let id: Int? // TODO: 0.18 Deprecation remove this field
    let personId: Int
    let postCount: Int
    let postScore: Int? // TODO: 0.18 Deprecation remove this field
    let commentCount: Int
    let commentScore: Int? // TODO: 0.18 Deprecation remove this field
}

extension APIPersonAggregates: Mockable {
    static var mock: APIPersonAggregates { .init() }
}
