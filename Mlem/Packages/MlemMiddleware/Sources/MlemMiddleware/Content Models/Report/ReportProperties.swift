//
//  ReportProperties.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-10-12.
//

import Foundation

public struct ReportProperties: UnifiedPropertiesProviding {
    // From ReportSnapshot, guaranted to always be present
    let id: Int
    let created: Date
    let creator: Person
    let target: ReportTarget
    var resolver: Person?
    var updated: Date?
    var resolved: Bool
    var reason: String
    
    @MainActor
    public init(api: ApiClient, snapshot: ReportSnapshot, myPersonId: Int) {
        id = snapshot.id
        created = snapshot.created
        creator = api.caches.person.getModel(api: api, from: .person1(snapshot.creator))
        if let resolverSnapshot = snapshot.resolver {
            resolver = api.caches.person.getModel(api: api, from: .person1(resolverSnapshot))
        }
        target = .init(from: snapshot.target, api: api, myPersonId: myPersonId)
        updated = snapshot.updated
        resolved = snapshot.resolved
        reason = snapshot.reason
    }
    
    public mutating func merge(_ other: ReportProperties) {
        self.resolver = other.resolver
        self.updated = other.updated
        self.resolved = other.resolved
        self.reason = other.reason
    }
}
