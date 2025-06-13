//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-08.
//

import Foundation

public extension LemmyConnection {
    func getMyInstance() async throws -> Instance3Snapshot {
        let response = try await rawGetMyPersonWithContext()
        return try .init(from: response)
    }
    
    func getFederatedInstances() async throws -> FederationPolicy {
        let response = try await performingForEndpoint { endpoint in
            GetFederatedInstancesRequest(endpoint: endpoint)
        }
        if let federatedInstances = response.federatedInstances {
            return .init(from: federatedInstances)
        }
        throw ApiClientError.noEntityFound
    }
    
    func blockInstance(instanceId: Int, block: Bool) async throws {
        _ = try await performingForEndpoint { endpoint in
            UserBlockInstanceRequest(endpoint: endpoint, instanceId: instanceId, block: block)
        }
    }
    
    @discardableResult
    func addAdmin(personId: Int, added: Bool) async throws -> [Person2Snapshot] {
        let response = try await performingForEndpoint { endpoint in
            AddAdminRequest(endpoint: endpoint, personId: personId, added: added)
        }
        return try response.admins.map { try .init(from: $0) }
    }
}
