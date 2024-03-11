//
//  ModlogEntry.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-11.
//

import Foundation

enum ModlogContext: Hashable, Identifiable {
    case user(APIPerson)
    case post(APIPost)
    case comment(APIComment)
    case community(APICommunity)
    
    var id: Int { hashValue }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .user(user):
            hasher.combine("user")
            hasher.combine(user)
        case let .post(post):
            hasher.combine("post")
            hasher.combine(post)
        case let .comment(comment):
            hasher.combine("comment")
            hasher.combine(comment)
        case let .community(community):
            hasher.combine("community")
            hasher.combine(community)
        }
    }
}

protocol ModlogEntry {
    var date: Date { get }
    var description: String { get }
    var context: [ModlogContext] { get }
}

struct AnyModlogEntry: Hashable, Equatable {
    private let wrappedValue: any ModlogEntry
    
    var date: Date { wrappedValue.date }
    var description: String { wrappedValue.description }
    var context: [ModlogContext] { wrappedValue.context }
    
    init(wrappedValue: any ModlogEntry) {
        self.wrappedValue = wrappedValue
    }
    
    static func == (lhs: AnyModlogEntry, rhs: AnyModlogEntry) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(description)
    }
}
