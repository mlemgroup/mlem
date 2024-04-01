//
//  AppState.swift
//  Mlem
//
//  Created by Sjmarf on 17/02/2024.
//

import Dependencies
import Foundation

@Observable
class AppState {
    private(set) var api: ApiClient?
    private(set) var myUser: (any UserProviding)?
    
    var actorId: URL? { myUser?.actorId }
    var isOnboarding: Bool { api == nil }
    
    var safeApi: ApiClient {
        if let api { return api }
        assertionFailure(
            "This shouldn't happen! Maybe you should use `activeApi` instead?"
        )
        return .getApiClient(for: URL(string: "https://lemmy.world")!, with: nil)
    }

    func changeUser(to user: UserStub) {
        self.api?.locked = true
        user.api.locked = false
        self.api = user.api
        myUser = user
    }
    
    func enterGuestMode(with api: ApiClient) {
        self.api?.locked = true
        self.api = api
        myUser = nil
    }
    
    func enterOnboarding() {
        api = nil
    }
    
    private init() {
        @Dependency(\.accountsTracker) var accountsTracker
        if let user = accountsTracker.defaultAccount {
            changeUser(to: user)
        } else if let user = accountsTracker.savedAccounts.first {
            changeUser(to: user)
        }
    }
    
    var lemmyVersion: SiteVersion? { api?.version ?? myUser?.cachedSiteVersion }
    
    static var main: AppState = .init()
}
