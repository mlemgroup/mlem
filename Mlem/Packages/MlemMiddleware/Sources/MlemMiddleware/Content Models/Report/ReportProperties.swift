//
//  ReportProperties.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-08-30.
//

import Foundation

public struct ReportProperties: UnifiedPropertiesProviding {
    let creator: Person
    let id: Int
    let created: Date

    var resolver: Person?
    var updated: Date?
    var resolved: Bool
    var reason: String
    
    let target: ReportTarget
    
    public mutating func merge(_ other: ReportProperties) {
        // tier 1 properties: simple assignment (no higher tier properties exist)
        self.resolver = other.resolver
        self.updated = other.updated
        self.resolved = other.resolved
        self.reason = other.reason
    }
}
