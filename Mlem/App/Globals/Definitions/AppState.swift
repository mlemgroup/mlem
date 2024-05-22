//
//  AppState.swift
//  Mlem
//
//  Created by Sjmarf on 17/02/2024.
//

import Dependencies
import Foundation
import MlemMiddleware
import SwiftUI

@Observable
class AppState {
    private(set) var guestAccount: ActiveAccount = .init(instanceUrl: URL(string: "https://lemmy.world")!)
    private(set) var activeAccounts: [ActiveAccount] = []

    func changeUser(to account: Account) {
        ToastModel.main.add(.user(userStub))
        let newAccount = ActiveAccount(account: account)
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
    
    func deactivate(account: Account) {
        if let index = AppState.main.activeAccounts.firstIndex(where: { $0.account === account }) {
            activeAccounts[index].deactivate()
            activeAccounts.remove(at: index)
            if activeAccounts.isEmpty, let defaultAccount = AccountsTracker.main.defaultAccount {
                changeUser(to: defaultAccount)
            }
        }
    }
    
    func enterOnboarding() {
        activeAccounts.removeAll()
    }
    
    private init() {
        if let user = AccountsTracker.main.defaultAccount {
            changeUser(to: user)
        } else if let user = AccountsTracker.main.savedAccounts.first {
            changeUser(to: user)
        }
    }
    
    var firstAccount: ActiveAccount { activeAccounts.first ?? guestAccount }
    var firstApi: ApiClient { firstAccount.api }
    
    func accountThatModerates(actorId: URL) -> ActiveAccount? {
        activeAccounts.first(where: { account in
            account.person?.moderatedCommunities.contains { $0.actorId == actorId } ?? false
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
    private(set) var account: Account?
    private(set) var person: Person4?
    private(set) var instance: Instance3?
    private(set) var subscriptions: SubscriptionList?
    
    // TODO: Store this in a file; make sure to translate 1.0 favorites to 2.0 favorites
    private var favorites: Set<Int> = []
    
    var actorId: URL? { account?.actorId }
  
    init(account: Account) {
        self.api = account.api
        self.account = account
        api.permissions = .all
        self.subscriptions = api.setupSubscriptionList(
            getFavorites: { self.favorites },
            setFavorites: { self.favorites = $0 }
        )
        
        Task {
            try await self.api.fetchSiteVersion(task: Task {
                let (person, instance) = try await self.api.getMyPerson()
                if let person {
                    self.account?.update(person: person, instance: instance)
                    self.person = person
                }
                self.instance = instance
                return instance.version
            })
            
            try await self.api.getSubscriptionList()
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
