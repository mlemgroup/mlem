//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-08.
//

import Foundation

public extension PieFedConnection {
    func getMyInstance() async throws -> Instance3Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getFederatedInstances() async throws -> FederationPolicy {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func blockInstance(instanceId: Int, block: Bool) async throws {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func addAdmin(personId: Int, added: Bool) async throws -> [Person2Snapshot] {
        throw ApiClientError.unsupportedLemmyVersion
    }
}
