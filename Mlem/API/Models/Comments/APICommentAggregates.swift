//
//  APICommentAggregates.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

struct APICommentAggregates: Decodable {
    let childCount: Int
    let commentId: Int
    let downvotes: Int
    let id: Int
    let score: Int
    let upvotes: Int
}
