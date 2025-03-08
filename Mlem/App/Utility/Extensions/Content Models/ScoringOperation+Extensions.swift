//
//  ScoringOperation+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-18.
//

import MlemMiddleware
import SwiftUI
import Theming

extension ScoringOperation {
    var systemImage: String {
        switch self {
        case .none: Icons.resetVoteSquare
        case .upvote: Icons.upvoteSquare
        case .downvote: Icons.downvoteSquare
        }
    }
    
    var color: ThemedColor {
        switch self {
        case .none: .themedSecondary
        case .upvote: .themedUpvote
        case .downvote: .themedDownvote
        }
    }
}
