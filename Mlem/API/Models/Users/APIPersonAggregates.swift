//
//  APIPersonAggregates.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

struct APIPersonAggregates: Decodable {
    let commentCount: Int
    let commentScore: Int
    let id: Int
    let personId: Int
    let postCount: Int
    let postScore: Int
}
