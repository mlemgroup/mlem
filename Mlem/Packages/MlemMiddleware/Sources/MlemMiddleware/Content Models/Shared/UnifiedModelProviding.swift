//
//  UnifiedModelProviding.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-07.
//

public protocol UnifiedModelProviding: AnyObject, CacheIdentifiable, ContentModel {
    associatedtype Properties: UnifiedPropertiesProviding
    
    /// Updates with the values from the given Properties, preferring the incoming values. Should only be called
    /// from the `UpdateQueue`
    @MainActor func update(with properties: Properties)
    
    /// Updates only values that are currently nil with values from the given Properties. Safe to call outside the `UpdateQueue`
    @MainActor func softUpdate(with properties: Properties)
    
    /// Retrieves a fully populated Properties for this model
    func fetchUpgraded() async throws -> Properties
    
    func resolve(with api: ApiClient) async throws -> Self
}

extension UnifiedModelProviding {
    @MainActor
    func setIfChanged<T: Equatable>(_ keyPath: ReferenceWritableKeyPath<Self, T>, _ value: T) {
        if self[keyPath: keyPath] != value {
            self[keyPath: keyPath] = value
        }
    }
    
    /// If the provided value is non-nil and different from the current value at the target key path, updates
    /// the target key path with the provided value
    @MainActor
    func updateIfChanged<T: Equatable>(_ keyPath: ReferenceWritableKeyPath<Self, T?>, _ value: T?) {
        if let value, self[keyPath: keyPath] != value {
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

enum ModelError: Error {
    case notUpgradable, notResolvable
}
