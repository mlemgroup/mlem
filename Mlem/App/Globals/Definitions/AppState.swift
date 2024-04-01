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
    private var activeApi: ApiClient?
    private(set) var myUser: (any UserProviding)?
    private(set) var myInstance: Instance3?
    
    var actorId: URL? { myUser?.actorId }
    var isOnboarding: Bool { activeApi == nil }
    
    var api: ApiClient {
        if let activeApi { return activeApi }
        assertionFailure("This shouldn't be allowed!")
        return .getApiClient(for: URL(string: "https://lemmy.world")!, with: nil)
    }

    func changeUser(to user: UserStub) {
        self.setApi(user.api)
        myUser = user
    }
    
    func enterGuestMode(with api: ApiClient) {
        self.setApi(api)
        myUser = nil
    }
    
    private func setApi(_ newApi: ApiClient) {
        self.activeApi?.isActive = false
        self.activeApi = newApi
        newApi.isActive = true
        self.myInstance = nil
        Task {
            try await newApi.fetchSiteVersion(task: Task {
                let site = try await newApi.getSite()
                self.myInstance = site
                return site.version
            })
        }
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
    
    var lemmyVersion: SiteVersion? { activeApi?.fetchedVersion ?? myUser?.cachedSiteVersion }
    
    static var main: AppState = .init()
}
