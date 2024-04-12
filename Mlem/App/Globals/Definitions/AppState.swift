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
    var activeAccounts: [ActiveAccount] = []
    var isOnboarding: Bool { activeAccounts.isEmpty }

    func changeUser(to userStub: UserStub) {
        let newAccount = ActiveAccount(userStub.api, userStub: userStub)
        activeAccounts.forEach { $0.deactivate() }
        activeAccounts = [newAccount]
    }
    
    func enterGuestMode(with api: ApiClient) {
        let newAccount = ActiveAccount(api)
        activeAccounts.forEach { $0.deactivate() }
        activeAccounts = [newAccount]
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
    
    var firstAccount: ActiveAccount { activeAccounts.first ?? .mock }
    var firstApi: ApiClient { firstAccount.api }
    
    func accountThatModerates(actorId: URL) -> ActiveAccount? {
        return activeAccounts.first(where: { account in
            account.user?.moderatedCommunities.contains { $0.actorId == actorId } ?? false
        }) ?? .mock
    }
    
    func cleanCaches() {
        for account in activeAccounts {
            account.api.cleanCaches()
        }
    }
    
    static var main: AppState = .init()
}

class ActiveAccount: Hashable {
    var api: ApiClient
    private(set) var userStub: UserStub?
    private(set) var user: User?
    private(set) var instance: Instance3?
    
    var actorId: URL? { userStub?.actorId }
    
    init(_ newApi: ApiClient, userStub: UserStub? = nil) {
        self.api = newApi
        newApi.permissions = .all
        self.instance = nil
        self.userStub = userStub
        if newApi.permissions != .none {
            Task {
                try await newApi.fetchSiteVersion(task: Task {
                    let (user, instance) = try await newApi.getMyUser(userStub: userStub)
                    if let user {
                        self.user = user
                    }
                    self.instance = instance
                    return instance.version
                })
            }
        }
    }
    
    static var mock: ActiveAccount = .init(ApiClient.mock)
    
    func deactivate() {
        self.api.permissions = .none
        self.api.cleanCaches()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(actorId)
    }
    
    static func == (lhs: ActiveAccount, rhs: ActiveAccount) -> Bool {
        lhs.actorId == rhs.actorId
    }
}
