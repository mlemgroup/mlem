//
//  ScoringOperation.swift
//  Mlem
//
//  Created by mormaer on 16/08/2023.
//
//

import Foundation

enum ScoringOperation: Int, Decodable {
    case upvote = 1
    case downvote = -1
    case resetVote = 0
}
