//
//  CommentMockType.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-17.
//

import Foundation
import MlemMiddleware

enum CommentMockType {
    case generic
    
    var id: Int {
        switch self {
        case .generic: 0
        }
    }
    
    var content: String {
        switch self {
        // swiftlint:disable:next line_length
        case .generic: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        }
    }
    
    var created: Date {
        var generator = SeededRandomNumberGenerator(seed: id)
        let lowerBound = 60 * 60 * 1 // 1h
        let upperBound = 60 * 60 * 24 // 24h
        let timeInterval = TimeInterval(Int.random(in: lowerBound ... upperBound, using: &generator))
        return .now.addingTimeInterval(-timeInterval)
    }
    
    var votes: VotesModel {
        var generator = SeededRandomNumberGenerator(seed: id)
        let score = Int.random(in: 100 ... 1000, using: &generator)
        return .init(upvotes: Int(Double(score) * 0.8), downvotes: Int(Double(score) * 0.2), myVote: .none)
    }
    
    var post: PostMockType {
        switch self {
        case .generic: .generic
        }
    }
    
    var creator: PersonMockType {
        switch self {
        case .generic: .generic
        }
    }
    
    var parentComments: [CommentMockType] {
        switch self {
        case .generic: []
        }
    }
    
    var commentCount: Int {
        var generator = SeededRandomNumberGenerator(seed: id)
        return Int.random(in: 0 ... 50, using: &generator)
    }
}
