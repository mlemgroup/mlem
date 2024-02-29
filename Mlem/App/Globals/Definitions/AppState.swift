//
//  AppState.swift
//  Mlem
//
//  Created by Sjmarf on 17/02/2024.
//

import Foundation

@Observable
class AppState {
    var isOnboarding: Bool = false

    var myInstance: (any InstanceStubProviding)?
    var myUser: (any UserProviding)?
    
    var api: ApiClient // TODO: is this even needed?
    var actorId: URL?
    var instanceStub: InstanceStub
    
    /// Initializer for a guest mode app state
    /// - Parameters:
    ///   - instance: instance to connect to
    init(instance: InstanceStub) {
        self.api = instance.api
        self.actorId = nil
        self.instanceStub = instance
    }
    
    /// Initializer for an authenticated app state
    /// - Parameter user: user to connect with
    init(user: UserStub) {
        self.api = user.api
        self.actorId = user.actorId
        self.instanceStub = user.instance
    }
    
    var lemmyVersion: SiteVersion? { myInstance?.version_ ?? myUser?.cachedSiteVersion }
}
