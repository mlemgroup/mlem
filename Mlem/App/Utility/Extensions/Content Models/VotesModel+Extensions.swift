//
//  VotesModel+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-17.
//

import Foundation
import MlemMiddleware
import SwiftUI

extension VotesModel {
    var iconName: String {
        switch myVote {
        case .upvote: Icons.upvoteSquareFill
        case .downvote: Icons.downvoteSquareFill
        case .none: Icons.upvoteSquare
        }
    }
    
    var iconColor: Color {
        switch myVote {
        case .upvote: Palette.main.upvote
        case .downvote: Palette.main.downvote
        case .none: Palette.main.secondary
        }
    }
}
