//
//  File.swift
//
//
//  Created by Sjmarf on 28/05/2024.
//

import Foundation
import os

public enum InstanceUpgradeError: Error {
    case noPostReturned
    case noCommunityReturned
    case noSiteReturned
}

public struct InstanceStub: Hashable {
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
    
    /// Gets the instance this stub refers to using that instance's local API
    public func getLocalInstance() async throws -> Instance {
        return try await self.asLocal().api.getMyInstance()
    }
    
    /// Gets the instance this stub refers to using the stub's current API
    public func getInstance() async throws -> Instance {
        let community = try await api.getCommunityOfInstance(actorId: actorId)
        let instance = try await community.fetchUpgraded().instance
  
        guard let instance = instance as? Instance else {
            throw InstanceUpgradeError.noSiteReturned
        }
        return instance
    }
}
