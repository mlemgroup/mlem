//
//  UnifiedModelProviding.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-07.
//

public protocol UnifiedModelProviding: AnyObject, CacheIdentifiable, ContentModel {
    associatedtype Properties: UnifiedPropertiesProviding
    
    // var properties: Properties { get set }
    @MainActor func update(with properties: Properties)
    @MainActor func softUpdate(with properties: Properties)
    
    func fetchUpgraded() async throws -> Properties
}

extension UnifiedModelProviding {
    @MainActor
    func setIfChanged<T: Equatable>(_ keyPath: ReferenceWritableKeyPath<Self, T>, _ value: T) {
        if self[keyPath: keyPath] != value {
            self[keyPath: keyPath] = value
        }
    }
    
    /// If the current value at the target key path is nil, udpates it with the provided value
    @MainActor
    func setIfNil<T>(_ keyPath: ReferenceWritableKeyPath<Self, T?>, _ value: T?) {
        if self[keyPath: keyPath] == nil {
            self[keyPath: keyPath] = value
        }
    }
}
