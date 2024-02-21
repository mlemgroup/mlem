//
//  ScoringOperation.swift
//  Mlem
//
//  Created by mormaer on 16/08/2023.
//
//

import Foundation
import SwiftUI

enum ScoringOperation: Int, Decodable {
    case upvote = 1
    case downvote = -1
    case none = 0
    
    var upvoteValue: Int { self == .upvote ? 1 : 0 }
    var downvoteValue: Int { self == .downvote ? 1 : 0 }
}

extension ScoringOperation: AssociatedColor {
    var color: Color? {
        switch self {
        case .upvote: return .upvoteColor
        case .downvote: return .downvoteColor
        case .none: return nil
        }
    }
}

extension ScoringOperation: AssociatedIcon {
    var buttonIconName: String {
        switch self {
        case .downvote:
            return Icons.downvote
        default:
            return Icons.upvote
        }
    }
    
    var iconName: String {
        switch self {
        case .upvote: return Icons.upvoteSquare
        case .downvote: return Icons.downvoteSquare
        case .none: return Icons.resetVoteSquare
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .upvote: return Icons.upvoteSquareFill
        case .downvote: return Icons.downvoteSquareFill
        case .none: return Icons.resetVoteSquareFill
        }
    }
}
