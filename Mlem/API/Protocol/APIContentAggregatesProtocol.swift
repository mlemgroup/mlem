//
//  APIContentAggregatesProtocol.swift
//  Mlem
//
//  Created by Sjmarf on 09/08/2023.
//

import Foundation

protocol APIContentAggregatesProtocol {
    var score: Int { get }
    var upvotes: Int { get }
    var downvotes: Int { get }
    var published: Date { get }
    var comments: Int { get }
}
