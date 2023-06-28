//
//  APIPersonAggregates.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::aggregates::structs::PersonAggregates
struct APIPersonAggregates: Decodable {
    let id: Int
    let personId: Int
    let postCount: Int
    let postScore: Int
    let commentCount: Int
    let commentScore: Int
}
