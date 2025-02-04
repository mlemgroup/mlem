//
//  PostMockType.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-04.
//  

import Foundation
import MlemMiddleware

// swiftlint:disable line_length
enum PostMockType {
    case generic
    
    var id: Int {
        switch self {
        case .generic: 0
        }
    }
    
    var title: String {
        switch self {
        case .generic:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        }
    }
    
    var content: String? {
        switch self {
        case .generic:
            "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        }
    }
    
    var created: Date {
        switch self {
        case .generic: .now.addingTimeInterval(-60 * 60 * 5)
        }
    }
    
    var votes: VotesModel {
        switch self {
        case .generic: .init(upvotes: 7, downvotes: 1, myVote: .none)
        }
    }
    
    var creator: Person1 {
        switch self {
        case .generic: .mock(.generic)
        }
    }
    
    var community: Community1 {
        switch self {
        case .generic: .mock(.generic)
        }
    }
    
    var commentCount: Int {
        var generator = SeededRandomNumberGenerator(seed: id)
        return Int.random(in: 0 ... 50, using: &generator)
    }
}
// swiftlint:enable line_length
