//
//  VotesModel+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-17.
//

import Foundation
import MlemMiddleware
import SwiftUI
import Theming

extension VotesModel {
    var iconName: String {
        switch myVote {
        case .upvote: Icons.upvoteSquareFill
        case .downvote: Icons.downvoteSquareFill
        case .none: Icons.upvoteSquare
        }
    }
    
    var iconColor: ThemedColor {
        switch myVote {
        case .upvote: .themedUpvote
        case .downvote: .themedDownvote
        case .none: .themedSecondary
        }
    }
}
