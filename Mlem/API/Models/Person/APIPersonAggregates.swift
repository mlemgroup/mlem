//
//  APIPersonAggregates.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::aggregates::structs::PersonAggregates
struct APIPersonAggregates: Decodable {
    let id: Int? // TODO: 0.18 Deprecation remove this field
    let personId: Int
    let postCount: Int
    let postScore: Int? // TODO: 0.18 Deprecation remove this field
    let commentCount: Int
    let commentScore: Int? // TODO: 0.18 Deprecation remove this field
}
