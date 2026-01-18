//
//  UnifiedModelProviding.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-07.
//

public protocol UnifiedModelProviding: AnyObject, CacheIdentifiable, ContentModel {
    associatedtype Properties: UnifiedPropertiesProviding
    
    var properties: Properties { get set }
    @MainActor func update(with properties: Properties)
    func fetchUpgraded() async throws -> Properties
}
