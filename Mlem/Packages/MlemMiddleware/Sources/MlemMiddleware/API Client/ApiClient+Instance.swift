//
//  NewApiClient+Site.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

public extension ApiClient {
    func getMyInstance() async throws -> Instance3 {
        let response = try await performingForConnection { connection in
            try await connection.getMyInstance()
        }
        let model = await caches.instance3.getModel(api: self, from: response)
        model.local = true
        _ = await Task { @MainActor in
            myInstance = model
        }.result
        return model
    }
    
    func getFederatedInstances() async throws -> FederationPolicy {
        let response = try await performingForConnection { connection in
            try await connection.getFederatedInstances()
        }
        return response
    }
    
    /// Returns `true` if federated, `false` if not federated, or `nil` if the status could not be determined.
    func federatedWith(with url: URL) async throws -> FederationStatus? {
        guard let domain = url.host() else { throw ApiClientError.invalidInput }
        let federatedInstances = try await getFederatedInstances()
        if !federatedInstances.blocked.isEmpty {
            return federatedInstances.blocked.contains(domain) ? .explicitlyBlocked : .implicitlyAllowed
        } else if !federatedInstances.allowed.isEmpty {
            return federatedInstances.allowed.contains(domain) ? .explicitlyAllowed : .implicitlyBlocked
        }
        return nil
    }
    
    /// `instanceId` is distinct from `id`. Make sure to pass `instance.instanceId` and not `id`.
    ///  Technically only `instanceId` is needed to perform this request, but `actorId` is also needed to properly update the `BlockList`.
    func blockInstance(url: URL, instanceId: Int, block: Bool, semaphore: UInt? = nil) async throws {
        guard let host = url.host() else { throw ApiClientError.invalidInput }
        let actorId: ActorIdentifier = .instance(host: host)
        try await performingForConnection { connection in
            try await connection.blockInstance(instanceId: instanceId, block: block)
        }
        let newBlockState: Bool = block
        if let instance = caches.instance1.retrieveModel(instanceId: instanceId) {
            instance.blockedManager.updateWithReceivedValue(newBlockState, semaphore: semaphore)
        }
        if newBlockState {
            blocks?.instances[actorId] = instanceId
        } else {
            blocks?.instances.removeValue(forKey: actorId)
        }
    }
    
    /// Adds or removes an admin from this API's instance
    @discardableResult
    func addAdmin(personId: Int, added: Bool) async throws -> [Person2] {
        let response = try await performingForConnection { connection in
            try await connection.addAdmin(personId: personId, added: added)
        }

        let updatedAdministrators = await caches.person2.getModels(api: self, from: response)
        
        // update person's admin status
        // only need to do this manually if removing admin, otherwise handled by above caching logic
        if !added, let person = caches.person2.retrieveModel(cacheId: personId) {
            person.isAdmin = false
        }
        
        // update instance admins
        if let myInstance {
            myInstance.administrators = updatedAdministrators
        }
        
        return updatedAdministrators
    }
}
