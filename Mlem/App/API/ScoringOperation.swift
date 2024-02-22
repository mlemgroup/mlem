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
}

extension ScoringOperation: AssociatedColor {
    var color: Color? {
        switch self {
        case .upvote: return Colors.upvoteColor
        case .downvote: return Colors.downvoteColor
        case .none: return nil
        }
    }
}

extension ScoringOperation: AssociatedIcon {
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
