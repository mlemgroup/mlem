//
//  AppState.swift
//  Mlem
//
//  Created by Sjmarf on 17/02/2024.
//

import Foundation

@Observable
class AppState {
    var myInstance: any InstanceStubProviding
    var myUser: (any UserProviding)?
    
    private var api: ApiClient
    var actorId: URL? { myUser?.actorId }
    
    func cleanCaches() {
        api.caches.clean()
        ApiClient.instanceCaches.clean()
    }
    
    func changeUser(to user: UserStub) {
        api = user.api
        myUser = user
        myInstance = user.instance
        myInstance.stub.setApi(user.api) // TODO: remove me and fix at cache level
    }
    
    func enterGuestMode(for instance: InstanceStub) {
        api = instance.api
        myUser = nil
        myInstance = instance
    }
    
    /// Initializer for a guest mode app state
    /// - Parameters:
    ///   - instance: instance to connect to
    init(instance: InstanceStub) {
        self.api = instance.api
        self.myUser = nil
        self.myInstance = instance
    }
    
    /// Initializer for an authenticated app state
    /// - Parameter user: user to connect with
    init(user: UserStub) {
        self.api = user.api
        self.myUser = user
        self.myInstance = user.instance
    }
    
    var lemmyVersion: SiteVersion? { myInstance.version_ ?? myUser?.cachedSiteVersion }
}
