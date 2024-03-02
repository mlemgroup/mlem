//
//  ScoringOperation.swift
//  Mlem
//
//  Created by mormaer on 16/08/2023.
//
//

import Foundation
import SwiftUI

enum ScoringOperation: Int, Decodable, CustomStringConvertible {
    case upvote = 1
    case downvote = -1
    case none = 0

    var upvoteValue: Int { self == .upvote ? 1 : 0 }
    var downvoteValue: Int { self == .downvote ? 1 : 0 }

    var description: String {
        switch self {
        case .upvote:
            "Upvote"
        case .downvote:
            "Downvote"
        case .none:
            "No Vote"
        }
    }
}

extension ScoringOperation {
    /// Non-optional initializer; if int is nil or invalid, returns .none
    static func guaranteedInit(from int: Int?) -> ScoringOperation {
        guard let int else {
            return .none
        }
        
        if let value = ScoringOperation(rawValue: int) {
            return value
        } else {
            return .none
        }
    }
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
