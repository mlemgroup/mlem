//
//  ModlogEntry.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-11.
//

import Foundation

protocol ModlogEntry {
    var date: Date { get }
    var description: String { get }
    var contextLinks: [LinkType] { get }
}

struct AnyModlogEntry: Hashable, Equatable {
    private let wrappedValue: any ModlogEntry
    
    var date: Date { wrappedValue.date }
    var description: String { wrappedValue.description }
    var contextLinks: [LinkType] { wrappedValue.contextLinks }
    
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
