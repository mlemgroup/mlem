//
//  File.swift
//
//
//  Created by Sjmarf on 28/05/2024.
//

import Foundation
import os

public struct InstanceStub: InstanceStubProviding, Hashable {
    public static var tierNumber: Int = 0
    public var api: ApiClient
    public let actorId: ActorIdentifier
    
    public var local: Bool { actorId.url == api.baseUrl }
    
    public init(api: ApiClient, actorId: ActorIdentifier) {
        self.api = api
        self.actorId = actorId
    }
    
    public func asLocal() -> Self {
        .init(api: .getApiClient(url: actorId.hostUrl, username: nil), actorId: actorId)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(actorId)
    }
    
    public static func == (lhs: InstanceStub, rhs: InstanceStub) -> Bool {
        lhs.actorId == rhs.actorId
    }
    
    public func getInstance() async throws -> Instance {
        let community = try await api.getCommunityOfInstance(actorId: actorId)
        Logger.dev.info("Got community")
        let instance = try await community.fetchUpgraded().instance
        Logger.dev.info("Got instance")
  
        guard let instance = instance as? Instance else {
            throw InstanceUpgradeError.noSiteReturned
        }
        
        Logger.dev.info("Returning instance")
        
//        Logger.dev.info("Found community \(community.name) in instance \(actorId)")
//        Logger.dev.info("Associated instance: \(community.instance.value != nil)")
//        
//        guard let instance = try await api.getCommunityOfInstance(actorId: actorId).instance.value as? Instance else {
//            throw InstanceUpgradeError.noSiteReturned
//        }
        return instance
    }
}

// These are defined here rather than in `InstanceStubProviding`
// because `upgrade()` only goes up to `Instance1`, not `Instance3`.
// The names of `upgrade` methods on higher-tier models would be
// misleading because they would instead downgrade the model.
//public extension InstanceStub {
//    /// Upgrades to an ``Instance1`` -  the highest tier that can be upgraded to without using the local ``ApiClient`` instead.
//    /// Use ``upgradeLocal()`` if you need an ``Instance3``. This method does not work for locally running instances.
//    ///
//    /// Due to API limitations (see [here](https://github.com/mlemgroup/mlem/pull/1029#issuecomment-2067746011)),
//    /// it takes 4 API calls to perform this upgrade.
//    func upgrade() async throws -> Instance1 {
//        let comm = try await self.api.getCommunityOfInstance(actorId: actorId)
//
//        guard let instance = comm.instance.value_ as? Instance1 else {
//            throw InstanceUpgradeError.noSiteReturned
//        }
//        
//        return instance
//    }
//}
