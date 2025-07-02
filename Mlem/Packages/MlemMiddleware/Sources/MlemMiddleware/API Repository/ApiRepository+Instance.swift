//
//  ApiRepository+Instance.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-02.
//

public extension ApiRepository {
    func getMyInstance() async throws -> Instance3Snapshot {
        return try await performingForConnection { connection in
            try await connection.getMyInstance()
        }
    }
    
    func getFederatedInstances() async throws -> FederationPolicy {
        let response = try await performingForConnection { connection in
            try await connection.getFederatedInstances()
        }
        return response
    }
    
    func blockInstance(instanceId: Int, block: Bool) async throws {
        try await performingForConnection { connection in
            try await connection.blockInstance(instanceId: instanceId, block: block)
        }
    }
    
    func addAdmin(personId: Int, added: Bool) async throws -> [Person2Snapshot] {
        try await performingForConnection { connection in
            try await connection.addAdmin(personId: personId, added: added)
        }
    }
}
