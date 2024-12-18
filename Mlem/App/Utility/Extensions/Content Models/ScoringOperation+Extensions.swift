//
//  ScoringOperation+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-18.
//

import MlemMiddleware
import SwiftUI

extension ScoringOperation {
    var systemImage: String {
        switch self {
        case .none: Icons.resetVoteSquare
        case .upvote: Icons.upvoteSquare
        case .downvote: Icons.downvoteSquare
        }
    }
    
    var color: Color {
        switch self {
        case .none: Palette.main.secondary
        case .upvote: Palette.main.upvote
        case .downvote: Palette.main.downvote
        }
    }
}
