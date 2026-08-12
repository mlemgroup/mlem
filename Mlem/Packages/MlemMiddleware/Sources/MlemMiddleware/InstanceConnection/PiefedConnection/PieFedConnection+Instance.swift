//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-08.
//

import Foundation

public extension PieFedConnection {
    func getMyInstance() async throws -> Instance3Snapshot {
        let response = try await rawGetMyPersonWithContext()
        return try .init(pieFed: response.0, lemmy: response.1)
    }
    
    func getFederatedInstances() async throws -> FederationPolicy {
        throw ApiClientError.featureUnsupported
    }
    
    func blockInstance(instanceId: Int, block: Bool) async throws {
        let request = PieFedBlockInstanceRequest(
            block: block,
            instanceId: instanceId
        )
        try await perform(request)
    }
    
    @discardableResult
    func addAdmin(personId: Int, added: Bool) async throws -> [Person2Snapshot] {
        throw ApiClientError.featureUnsupported
    }
}
