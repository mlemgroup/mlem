//
//  UnifiedModelProviding.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-07.
//

public protocol UnifiedModelProviding: AnyObject, CacheIdentifiable, ContentModel {
    associatedtype Properties: UnifiedPropertiesProviding
    
    /// Updates with the values from the given Properties, preferring the incoming values
    @MainActor func update(with properties: Properties)
    
    /// Updates only values that are currently nil with values from the given Properties
    @MainActor func softUpdate(with properties: Properties)
    
    /// Retrieves a fully populated Properties for this model
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
