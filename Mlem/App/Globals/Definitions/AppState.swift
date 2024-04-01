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
    private(set) var activeApi: ApiClient?
    private(set) var myUser: (any UserProviding)?
    var actorId: URL? { myUser?.actorId }
    var isOnboarding: Bool { activeApi == nil }
    
    var api: ApiClient {
        if let activeApi { return activeApi }
        assertionFailure(
            "This shouldn't happen! Maybe you should use `activeApi` instead?"
        )
        return .getApiClient(for: URL(string: "https://lemmy.world")!, with: nil)
    }

    func changeUser(to user: UserStub) {
        self.activeApi?.locked = true
        user.api.locked = false
        self.activeApi = user.api
        myUser = user
    }
    
    func enterGuestMode(with api: ApiClient) {
        self.activeApi = api
        myUser = nil
    }
    
    func enterOnboarding() {
        activeApi = nil
    }
    
    private init() {
        @Dependency(\.accountsTracker) var accountsTracker
        if let user = accountsTracker.defaultAccount {
            changeUser(to: user)
        } else if let user = accountsTracker.savedAccounts.first {
            changeUser(to: user)
        }
    }
    
    var lemmyVersion: SiteVersion? { activeApi?.version ?? myUser?.cachedSiteVersion }
    
    static var main: AppState = .init()
}
