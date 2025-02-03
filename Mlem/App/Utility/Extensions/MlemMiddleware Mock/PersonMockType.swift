//
//  PersonMockType.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-02.
//

import Foundation
import MlemMiddleware

enum PersonMockType: Identifiable {
    case realistic(Realistic)
    case johnDoe
    
    var id: Int {
        switch self {
        case let .realistic(value): 100 + value.id
        case .johnDoe: 0
        }
    }
    
    var actorId: ActorIdentifier {
        switch self {
        case let .realistic(value):
            .mockPerson(name: value.name)
        case .johnDoe:
            .init(url: URL(string: "https://example.com/u/\(name)")!)!
        }
    }
    
    var name: String {
        switch self {
        case let .realistic(value): value.name
        case .johnDoe: "john_doe"
        }
    }
    
    var displayName: String {
        switch self {
        case let .realistic(value): value.displayName
        case .johnDoe: "John Doe"
        }
    }
    
    var description: String? {
        switch self {
        case let .realistic(value): value.description
        case .johnDoe: "ABC"
        }
    }
    
    var avatar: URL? {
        switch self {
        case let .realistic(value): value.avatar
        case .johnDoe: nil
        }
    }
    
    var banner: URL? {
        switch self {
        case let .realistic(value): value.banner
        case .johnDoe: nil
        }
    }
    
    var created: Date {
        var generator = SeededRandomNumberGenerator(seed: id)
        let lowerBound = 60 * 5 // 5h
        let upperBound = 60 * 60 * 24 * 365 * 2 // 2y
        let timeInterval = TimeInterval(Int.random(in: lowerBound ... upperBound, using: &generator))
        return .now.addingTimeInterval(-timeInterval)
    }
    
    var matrixId: String? {
        switch self {
        case let .realistic(value): value.matrixId
        case .johnDoe: nil
        }
    }
    
    var isBot: Bool {
        switch self {
        case let .realistic(value): value.isBot
        case .johnDoe: false
        }
    }
    
    var postCount: Int {
        var generator = SeededRandomNumberGenerator(seed: id)
        return Int.random(in: 0 ... 100, using: &generator)
    }
    
    var commentCount: Int {
        var generator = SeededRandomNumberGenerator(seed: id)
        return Int.random(in: 0 ... 700, using: &generator)
    }
}
