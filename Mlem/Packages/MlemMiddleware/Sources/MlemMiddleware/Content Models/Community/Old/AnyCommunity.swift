//
//  AnyCommunity.swift
//
//
//  Created by Sjmarf on 23/06/2024.
//

import Foundation

@Observable
public class AnyCommunity: Hashable, Upgradable {
    public typealias Base = CommunityStubProviding
    public typealias MinimumRenderable = Community1Providing
    public typealias Upgraded = Community3Providing
    
    public var wrappedValue: any CommunityStubProviding
    
    public required init(_ wrappedValue: any CommunityStubProviding) {
        self.wrappedValue = wrappedValue
    }
}

/// Hashable, Equatable conformance
public extension AnyCommunity {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    static func == (lhs: AnyCommunity, rhs: AnyCommunity) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

/// Upgradable conformance
public extension AnyCommunity {
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
            initialValue = api === wrappedValue.api ? wrappedValue : CommunityStub(
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
                initialValue: wrappedValue.community2,
                upgradeOperation: upgradeOperation ?? { try await $0.upgrade() }
            )
        }
    }
}
