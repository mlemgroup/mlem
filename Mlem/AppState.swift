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
    
    var apiSource: (any APISource)? {
        willSet {
            myUser?.stub.makeInactive()
        }
        didSet {
            print("NEW API SOURCE \(apiSource?.actorId)")
            myInstance = apiSource?.instance
            myUser = apiSource as? UserStub
            myUser?.stub.makeActive()
        }
    }
    var myInstance: (any InstanceStubProviding)?
    var myUser: (any UserProviding)?
    
    var api: APIClient? { apiSource?.api }
    var actorId: URL? { apiSource?.actorId }
    var instanceStub: InstanceStub? { apiSource?.instance }
    
    init(apiSource: (any APISource)?) {
        print("APPSTATE INIT \(apiSource?.actorId)")
        self.apiSource = apiSource
        if apiSource == nil {
            self.isOnboarding = true
        }
    }
    
    var lemmyVersion: SiteVersion? { myInstance?.version_ ?? myUser?.cachedSiteVersion }
}
