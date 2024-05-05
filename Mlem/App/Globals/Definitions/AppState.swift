//
//  AppState.swift
//  Mlem
//
//  Created by Sjmarf on 17/02/2024.
//

import Dependencies
import Foundation
import MlemMiddleware

@Observable
class AppState {
    private(set) var guestAccount: ActiveAccount = .init(instanceUrl: URL(string: "https://lemmy.world")!)
    private(set) var activeAccounts: [ActiveAccount] = []

    func changeUser(to userStub: UserStub) {
        let newAccount = ActiveAccount(userStub: userStub)
        activeAccounts.forEach { $0.deactivate() }
        guestAccount.deactivate()
        activeAccounts = [newAccount]
    }
    
    func enterGuestMode(for instanceUrl: URL) {
        activeAccounts.forEach { $0.deactivate() }
        activeAccounts = []
        guestAccount.deactivate()
        guestAccount = .init(instanceUrl: instanceUrl)
    }
    
    func enterOnboarding() {
        activeAccounts.removeAll()
    }
    
    private init() {
        @Dependency(\.accountsTracker) var accountsTracker
        if let user = accountsTracker.defaultAccount {
            changeUser(to: user)
        } else if let user = accountsTracker.savedAccounts.first {
            changeUser(to: user)
        }
    }
    
    var firstAccount: ActiveAccount { activeAccounts.first ?? guestAccount }
    var firstApi: ApiClient { firstAccount.api }
    
    func accountThatModerates(actorId: URL) -> ActiveAccount? {
        activeAccounts.first(where: { account in
            account.user?.moderatedCommunities.contains { $0.actorId == actorId } ?? false
        })
    }
    
    func cleanCaches() {
        for account in activeAccounts {
            account.api.cleanCaches()
        }
    }
    
    static var main: AppState = .init()
}

@Observable
class ActiveAccount: Hashable {
    private(set) var api: ApiClient
    private(set) var userStub: UserStub?
    private(set) var user: User?
    private(set) var instance: Instance3?
    
    var actorId: URL? { userStub?.actorId }
  
    init(userStub: UserStub) {
        self.api = userStub.api
        api.permissions = .all
        Task {
            try await self.api.fetchSiteVersion(task: Task {
                let (user, instance) = try await self.api.getMyUser(userStub: userStub)
                if let user {
                    self.user = user
                }
                self.instance = instance
                return instance.version
            })
        }
    }
    
    init(instanceUrl: URL) {
        self.api = .getApiClient(for: instanceUrl, with: nil)
        api.permissions = .all // should this be .getOnly?
    }
    
    func deactivate() {
        api.permissions = .getOnly
        api.cleanCaches()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(actorId)
    }
    
    static func == (lhs: ActiveAccount, rhs: ActiveAccount) -> Bool {
        lhs.actorId == rhs.actorId
    }
}
