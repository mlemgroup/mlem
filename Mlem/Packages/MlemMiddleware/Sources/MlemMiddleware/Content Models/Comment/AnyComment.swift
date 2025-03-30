//
//  AnyComment.swift
//
//
//  Created by Sjmarf on 25/06/2024.
//

import Foundation

@Observable
public class AnyComment: Hashable, Upgradable {
    public typealias Base = CommentStubProviding
    public typealias MinimumRenderable = Comment1Providing
    public typealias Upgraded = Comment2Providing
    
    public var wrappedValue: any CommentStubProviding
    
    public required init(_ wrappedValue: any CommentStubProviding) {
        self.wrappedValue = wrappedValue
    }
}

/// Hashable, Equatable conformance
public extension AnyComment {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    static func == (lhs: AnyComment, rhs: AnyComment) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

/// Upgradable conformance
public extension AnyComment {
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
            initialValue = api === wrappedValue.api ? wrappedValue : CommentStub(
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
                initialValue: wrappedValue.comment1,
                upgradeOperation: upgradeOperation ?? { try await $0.upgrade() }
            )
        }
    }
}
