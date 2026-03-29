//
//  NewApiClient+Site.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

public extension ApiClient {
    func getMyInstance() async throws -> Instance {
        let snapshot = try await repository.getMyInstance()
        let model = await caches.instance.getModel(api: self, from: .instance3(snapshot))
        model.local = true
        _ = await Task { @MainActor in
            myInstance = model
        }.result
        return model
    }
    
    /// Returns `true` if federated, `false` if not federated, or `nil` if the status could not be determined.
    func federatedWith(with url: URL) async throws -> FederationStatus? {
        guard let domain = url.host() else { throw ApiClientError.invalidInput }
        let federatedInstances = try await repository.getFederatedInstances()
        if !federatedInstances.blocked.isEmpty {
            return federatedInstances.blocked.contains(domain) ? .explicitlyBlocked : .implicitlyAllowed
        } else if !federatedInstances.allowed.isEmpty {
            return federatedInstances.allowed.contains(domain) ? .explicitlyAllowed : .implicitlyBlocked
        }
        return nil
    }

    /// Get any `Community3` hosted on the given instance.
    internal func getCommunityOfInstance(actorId: ActorIdentifier) async throws -> Community {
        let externalApi: ApiClient = .getApiClient(url: actorId.url, username: nil)
        
        let response = try await externalApi.getPosts(
            feed: .local,
            sort: .new,
            page: 1,
            cursor: nil,
            limit: 1
        )
        
        guard let post = response.posts.first else {
            throw InstanceUpgradeError.noPostReturned
        }
        
        guard let community = post.community.value_ else {
            throw InstanceUpgradeError.noCommunityReturned
        }
        
        return try await self.getCommunity(url: community.actorId.url)
    }

    func getInstanceId(actorId: ActorIdentifier) async throws -> Int {
        let comm = try await self.getCommunityOfInstance(actorId: actorId)
        return comm.instanceId
    }
    
    /// Adds or removes an admin from this API's instance
//    @discardableResult
//    func addAdmin(personId: Int, added: Bool) async throws -> [Person] {
//        let snapshots = try await repository.addAdmin(personId: personId, added: added)
//
//        let updatedAdministrators = await caches.person.getModels(api: self, from: snapshots.map { .person2($0) })
//        
//        // update person's admin status
//        // only need to do this manually if removing admin, otherwise handled by above caching logic
//        if !added, let person = caches.person.retrieveModel(cacheId: personId) {
//            person.isAdmin.value_ = false
//        }
//        
//        // update instance admins
//        if let myInstance {
//            myInstance.administrators = updatedAdministrators
//        }
//        
//        return updatedAdministrators
//    }
}
