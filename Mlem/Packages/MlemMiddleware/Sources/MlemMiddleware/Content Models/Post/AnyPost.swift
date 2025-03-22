//
//  AnyPost.swift
//
//
//  Created by Eric Andrews on 2024-05-13.
//

import Foundation

@Observable
public class AnyPost: Hashable, Upgradable {
    public typealias Base = PostStubProviding
    public typealias MinimumRenderable = Post1Providing
    public typealias Upgraded = Post3Providing
    
    public var wrappedValue: any PostStubProviding
    
    public required init(_ wrappedValue: any PostStubProviding) {
        self.wrappedValue = wrappedValue
    }
}

/// Hashable, Equatable conformance
public extension AnyPost {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    static func == (lhs: AnyPost, rhs: AnyPost) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

/// Upgradable conformance
public extension AnyPost {
    internal func upgrade(
        initialValue: (any Base)? = nil,
        upgradeOperation: (any Base) async throws -> any Base
    ) async throws {
        var lastValue = initialValue ?? wrappedValue
        while !(lastValue is any Upgraded) {
            lastValue = try await upgradeOperation(lastValue)
            if type(of: lastValue).tierNumber >= type(of: wrappedValue).tierNumber {
                let task = Task { @MainActor [lastValue] in
                    self.wrappedValue = lastValue
                }
                _ = await task.value
            }
        }
    }
    
    func upgrade(
        api: ApiClient?,
        upgradeOperation: ((any Base) async throws -> any Base)?
    ) async throws {
        let initialValue: any Base
        if let api {
            initialValue = api === wrappedValue.api ? wrappedValue : PostStub(
                api: api,
                url: wrappedValue.allResolvableUrls[0]
            )
        } else {
            initialValue = wrappedValue
        }
        try await upgrade(
            initialValue: initialValue,
            upgradeOperation: upgradeOperation ?? { try await $0.upgrade() }
        )
    }
    
    func refresh(upgradeOperation: ((any Base) async throws -> any Base)?) async throws {
        if let wrappedValue = wrappedValue as? any Upgraded {
            try await upgrade(
                initialValue: wrappedValue.post1,
                upgradeOperation: upgradeOperation ?? { try await $0.upgrade() }
            )
        }
    }
}
