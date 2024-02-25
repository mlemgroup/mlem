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
    
    var apiSource: (any ApiSource)? {
        willSet {
            (apiSource as? UserStub)?.makeInactive()
        }
        didSet {
            print("NEW API SOURCE \(apiSource?.actorId)")
            myInstance = apiSource?.instance
            let myUser = apiSource as? UserStub
            myUser?.makeActive()
            self.myUser = myUser
        }
    }

    var myInstance: (any InstanceStubProviding)?
    var myUser: (any UserProviding)?
    
    var api: ApiClient? { apiSource?.api }
    var actorId: URL? { apiSource?.actorId }
    var instanceStub: InstanceStub? { apiSource?.instance }
    
    init(apiSource: (any ApiSource)?) {
        print("APPSTATE INIT \(apiSource?.actorId)")
        self.apiSource = apiSource
        if apiSource == nil {
            self.isOnboarding = true
        }
    }
    
    var lemmyVersion: SiteVersion? { myInstance?.version_ ?? myUser?.cachedSiteVersion }
}
