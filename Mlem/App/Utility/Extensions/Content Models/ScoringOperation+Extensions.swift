//
//  ScoringOperation+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-18.
//

import Icons
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

    var icon: Icon {
        switch self {
        case .none: .lemmy.removeUpvote
        case .upvote: .lemmy.addUpvote
        case .downvote: .lemmy.addDownvote
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
