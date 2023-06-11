//
//  APIPostAggregates.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

struct APIPostAggregates: Decodable {
    let comments: Int
    let upvotes: Int
    let downvotes: Int
    var score: Int
}
