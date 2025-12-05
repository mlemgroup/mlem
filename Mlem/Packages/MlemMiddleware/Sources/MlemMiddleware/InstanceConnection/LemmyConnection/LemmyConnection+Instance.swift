//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-08.
//

import Foundation

public extension LemmyConnection {
    func getMyInstance() async throws -> Instance3Snapshot {
        let rawContext = try await getRawContextWithCaching()
        return try .init(from: rawContext.site)
    }
    
    func getFederatedInstances() async throws -> FederationPolicy {
        let response = try await performingForEndpoint { endpoint in
            LemmyGetFederatedInstancesRequest(endpoint: endpoint)
        }
        switch response {
        case let .lemmyLegacyGetFederatedInstancesResponse(response):
            if let federatedInstances = response.federatedInstances {
                return .init(from: federatedInstances)
            }
            throw ApiClientError.noEntityFound
        case let .lemmyPagedResponse(response):
            return .init(from: response.items)
        }
    }
    
    func blockInstance(instanceId: Int, block: Bool) async throws {
        _ = try await performingForEndpoint { endpoint in
            LemmyUserBlockInstanceCommunitiesRequest(endpoint: endpoint, instanceId: instanceId, block: block)
        }
    }
    
    @discardableResult
    func addAdmin(personId: Int, added: Bool) async throws -> [Person2Snapshot] {
        let response = try await performingForEndpoint { endpoint in
            LemmyAddAdminRequest(endpoint: endpoint, personId: personId, added: added)
        }
        return try response.admins.map { try .init(from: $0) }
    }
}
