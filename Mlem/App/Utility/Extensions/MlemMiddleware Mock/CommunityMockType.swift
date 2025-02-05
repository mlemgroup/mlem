//
//  CommunityMockType.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-03.
//

import Foundation
import MlemMiddleware

enum CommunityMockType {
    case realistic(Realistic)
    case generic
    
    var id: Int {
        switch self {
        case let .realistic(value): 100 + value.id
        case .generic: 0
        }
    }
    
    var actorId: ActorIdentifier {
        switch self {
        case let .realistic(value):
            .mockPerson(name: value.name)
        case .generic:
            .init(url: URL(string: "https://example.com/c/\(name)")!)!
        }
    }
    
    var name: String {
        switch self {
        case let .realistic(value): value.name
        case .generic: "community"
        }
    }
    
    var displayName: String {
        switch self {
        case let .realistic(value): value.displayName
        case .generic: "Community"
        }
    }
    
    var description: String? {
        switch self {
        case let .realistic(value): value.description
        case .generic: "ABC"
        }
    }
    
    var avatar: URL? {
        switch self {
        case let .realistic(value): value.avatar
        case .generic: nil
        }
    }
    
    var banner: URL? {
        switch self {
        case let .realistic(value): value.banner
        case .generic: nil
        }
    }
    
    var created: Date {
        var generator = SeededRandomNumberGenerator(seed: id)
        let lowerBound = 60 * 60 * 24 * 30 * 3 // 3mo
        let upperBound = 60 * 60 * 24 * 365 * 2 // 2y
        let timeInterval = TimeInterval(Int.random(in: lowerBound ... upperBound, using: &generator))
        return .now.addingTimeInterval(-timeInterval)
    }
    
    var subscriberCount: Int {
        var generator = SeededRandomNumberGenerator(seed: id)
        return Int.random(in: 500 ... 20000, using: &generator)
    }

    var localSubscriberCount: Int {
        var generator = SeededRandomNumberGenerator(seed: id)
        return Int.random(in: 100 ... 1000, using: &generator)
    }

    var postCount: Int {
        var generator = SeededRandomNumberGenerator(seed: id)
        return Int.random(in: 2000 ... 10000, using: &generator)
    }
    
    var commentCount: Int {
        var generator = SeededRandomNumberGenerator(seed: id)
        return Int.random(in: 5000 ... 25000, using: &generator)
    }
}
