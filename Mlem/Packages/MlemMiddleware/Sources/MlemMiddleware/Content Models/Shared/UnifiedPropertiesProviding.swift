//
//  UnifiedPropertiesProviding.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-07.
//

public protocol UnifiedPropertiesProviding {
    /// Merges the given properties into this one, preferring the incoming properties
    mutating func merge(_ other: Self)
}
