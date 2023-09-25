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

extension ScoringOperation: AssociatedIcon {
    var iconName: String {
        switch self {
        case .upvote: return Icons.upvoteSquare
        case .downvote: return Icons.downvoteSquare
        case .resetVote: return Icons.resetVoteSquare
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .upvote: return Icons.upvoteSquareFill
        case .downvote: return Icons.downvoteSquareFill
        case .resetVote: return Icons.resetVoteSquareFill
        }
    }
}
