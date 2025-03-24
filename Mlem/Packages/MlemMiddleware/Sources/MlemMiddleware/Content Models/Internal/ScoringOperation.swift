//
//  ScoringOperation.swift
//  Mlem
//
//  Created by mormaer on 16/08/2023.
//
//

import Foundation
import SwiftUI

public enum ScoringOperation: Int, Decodable, CustomStringConvertible {
    case upvote = 1
    case downvote = -1
    case none = 0

    public var upvoteValue: Int { self == .upvote ? 1 : 0 }
    public var downvoteValue: Int { self == .downvote ? 1 : 0 }

    public var description: String {
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

public extension ScoringOperation {
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
