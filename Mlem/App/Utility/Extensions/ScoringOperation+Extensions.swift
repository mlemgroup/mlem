//
//  ScoringOperation+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-28.
//

import Foundation
import MlemMiddleware
import SwiftUI

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
