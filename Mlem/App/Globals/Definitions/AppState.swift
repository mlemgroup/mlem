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
    var actorId: URL?
    
    func cleanCaches() {
        api.caches.clean()
    }
    
    func changeUser(to user: UserStub) {
        print("DEBUG changed user to \(user.accessToken)")
        print("DEBUG user instance token is \(user.instance.api.token)")
        self.api.token = user.accessToken
        self.actorId = user.actorId
        self.myInstance = user.instance
        self.myInstance.stub.setApi(user.api) // TODO: remove me and fix at cache level
    }
    
    /// Initializer for a guest mode app state
    /// - Parameters:
    ///   - instance: instance to connect to
    init(instance: InstanceStub) {
        self.api = instance.api
        self.actorId = nil
        self.myInstance = instance
    }
    
    /// Initializer for an authenticated app state
    /// - Parameter user: user to connect with
    init(user: UserStub) {
        // user.makeActive()
        self.api = user.api
        self.actorId = user.actorId
        self.myInstance = user.instance
    }
    
    var lemmyVersion: SiteVersion? { myInstance.version_ ?? myUser?.cachedSiteVersion }
}
