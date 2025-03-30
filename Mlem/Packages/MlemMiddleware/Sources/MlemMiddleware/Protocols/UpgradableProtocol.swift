//
//  UpgradableProtocol.swift
//
//
//  Created by Eric Andrews on 2024-05-13.
//

import Foundation

public protocol Upgradable: Observable {
    associatedtype Base
    associatedtype MinimumRenderable
    associatedtype Upgraded
    
    var wrappedValue: Base { get }
    
    func upgrade(api: ApiClient?, upgradeOperation: ((Base) async throws -> Base)?) async throws
    func refresh(upgradeOperation: ((Base) async throws -> Base)?) async throws
    
    init(_ wrappedValue: Base)
}

public extension Upgradable {
    var isRenderable: Bool { wrappedValue is MinimumRenderable }
    var isUpgraded: Bool { wrappedValue is Upgraded }
    
    func upgradeFromLocal() async throws {
        if let wrappedValue = wrappedValue as? any Resolvable {
            try await upgrade(
                api: .getApiClient(url: wrappedValue.allResolvableUrls[0].removingPathComponents(), username: nil),
                upgradeOperation: nil
            )
        } else {
            assertionFailure()
        }
    }
}
