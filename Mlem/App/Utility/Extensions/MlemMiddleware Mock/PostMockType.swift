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
    case realistic(Realistic)
    
    var id: Int {
        switch self {
        case .generic: 0
        case let .realistic(value): 100 + value.id
        }
    }
    
    var title: String {
        switch self {
        case .generic:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        case let .realistic(value): value.title
        }
    }
    
    var content: String? {
        switch self {
        case .generic:
            "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        case let .realistic(value): value.content
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
    
    var linkUrl: URL? {
        switch self {
        case .generic: nil
        case let .realistic(value): value.linkUrl
        }
    }
    
    var creator: PersonMockType {
        switch self {
        case .generic: .generic
        case let .realistic(value): .realistic(value.creator)
        }
    }
    
    var community: CommunityMockType {
        switch self {
        case .generic: .generic
        case let .realistic(value): .realistic(value.community)
        }
    }
    
    var commentCount: Int {
        var generator = SeededRandomNumberGenerator(seed: id)
        return Int.random(in: 0 ... 50, using: &generator)
    }
}

// swiftlint:enable line_length
