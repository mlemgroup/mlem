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
    private(set) var guestAccount: ActiveGuestAccount = .init(url: URL(string: "https://lemmy.world")!)
    private(set) var activeAccounts: [ActiveUserAccount] = []

    func changeAccount(to account: any Account) {
        ToastModel.main.add(.account(account))
        
        activeAccounts.forEach { $0.deactivate() }
        guestAccount.deactivate()
        
        // Save because we updated `lastUsed` in the above `deactivate()` calls
        AccountsTracker.main.saveAccounts()
        
        if let account = account as? UserAccount {
            let activeAccount = ActiveUserAccount(account: account)
            activeAccounts = [activeAccount]
        } else if let account = account as? GuestAccount {
            activeAccounts = []
            guestAccount = .init(account: account)
        } else {
            assertionFailure()
        }
    }
    
    func deactivate(account: UserAccount) {
        if let index = AppState.main.activeAccounts.firstIndex(where: { $0.account === account }) {
            activeAccounts[index].deactivate()
            activeAccounts.remove(at: index)
            if activeAccounts.isEmpty, let defaultAccount = AccountsTracker.main.defaultAccount {
                changeAccount(to: defaultAccount)
            } else {
                AccountsTracker.main.saveAccounts()
            }
        }
    }
    
    func enterOnboarding() {
        activeAccounts.removeAll()
    }
    
    private init() {
        if let user = AccountsTracker.main.defaultAccount {
            changeAccount(to: user)
        } else if let user = AccountsTracker.main.savedAccounts.first {
            changeAccount(to: user)
        }
    }
    
    var firstAccount: any ActiveAccount { activeAccounts.first ?? guestAccount }
    var firstApi: ApiClient { firstAccount.api }
    
    func accountThatModerates(actorId: URL) -> ActiveUserAccount? {
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
