//
//  AnyPerson.swift
//
//
//  Created by Sjmarf on 30/05/2024.
//

import Foundation

//@Observable
//public class AnyPerson: Hashable, Upgradable {
//    public typealias Base = PersonStubProviding
//    public typealias MinimumRenderable = Person1Providing
//    public typealias Upgraded = Person3Providing
//    
//    public var wrappedValue: any PersonStubProviding
//    
//    public required init(_ wrappedValue: any PersonStubProviding) {
//        self.wrappedValue = wrappedValue
//    }
//}
//
///// Hashable, Equatable conformance
//public extension AnyPerson {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(ObjectIdentifier(self))
//    }
//    
//    static func == (lhs: AnyPerson, rhs: AnyPerson) -> Bool {
//        lhs.hashValue == rhs.hashValue
//    }
//}
//
///// Upgradable conformance
//public extension AnyPerson {
//    internal func upgrade(
//        initialValue: (any Base)? = nil,
//        upgradeOperation: (any Base) async throws -> any Base
//    ) async throws {
//        var lastValue = initialValue ?? wrappedValue
//        while !(lastValue is any Upgraded) {
//            lastValue = try await upgradeOperation(lastValue)
//            if type(of: lastValue).tierNumber >= type(of: wrappedValue).tierNumber {
//                let task = Task { @MainActor [lastValue] in
//                    self.wrappedValue = lastValue
//                }
//                _ = await task.value
//            }
//        }
//    }
//    
//    func upgrade(
//        api: ApiClient?,
//        upgradeOperation: ((any Base) async throws -> any Base)?
//    ) async throws {
//        let initialValue: any Base
//        if let api {
//            initialValue = api === wrappedValue.api ? wrappedValue : PersonStub(
//                api: api,
//                url: wrappedValue.allResolvableUrls[0]
//            )
//        } else {
//            initialValue = wrappedValue
//        }
//        try await upgrade(
//            initialValue: initialValue,
//            upgradeOperation: upgradeOperation ?? { try await $0.upgrade() }
//        )
//    }
//    
//    func refresh(upgradeOperation: ((any Base) async throws -> any Base)?) async throws {
//        if let wrappedValue = wrappedValue as? any Upgraded {
//            try await upgrade(
//                initialValue: wrappedValue.person2,
//                upgradeOperation: upgradeOperation ?? { try await $0.upgrade() }
//            )
//        }
//    }
//}
