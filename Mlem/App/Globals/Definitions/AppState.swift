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
    private(set) var guestSession: GuestSession = .init(url: URL(string: "https://lemmy.world")!)
    private(set) var activeSessions: [UserSession] = []

    func changeAccount(to account: any Account) {
        ToastModel.main.add(.account(account))
        
        activeSessions.forEach { $0.deactivate() }
        guestSession.deactivate()
        
        // Save because we updated `lastUsed` in the above `deactivate()` calls
        AccountsTracker.main.saveAccounts(ofType: .all)
        
        if let account = account as? UserAccount {
            let activeAccount = UserSession(account: account)
            activeSessions = [activeAccount]
        } else if let account = account as? GuestAccount {
            activeSessions = []
            guestSession = .init(account: account)
        } else {
            assertionFailure()
        }
    }
    
    func deactivate(account: UserAccount) {
        if let index = AppState.main.activeSessions.firstIndex(where: { $0.account === account }) {
            activeSessions[index].deactivate()
            activeSessions.remove(at: index)
            if activeSessions.isEmpty, let defaultAccount = AccountsTracker.main.defaultAccount {
                changeAccount(to: defaultAccount)
            } else {
                AccountsTracker.main.saveAccounts(ofType: .all)
            }
        }
    }
    
    func enterOnboarding() {
        activeSessions.removeAll()
    }
    
    private init() {
        if let user = AccountsTracker.main.defaultAccount {
            changeAccount(to: user)
        } else if let user = AccountsTracker.main.userAccounts.first {
            changeAccount(to: user)
        }
    }
    
    var firstSession: any Session { activeSessions.first ?? guestSession }
    var firstAccount: any Account { firstSession.account }
    var firstApi: ApiClient { firstSession.api }
    
    func accountThatModerates(actorId: URL) -> UserSession? {
        activeSessions.first(where: { session in
            session.person?.moderatedCommunities.contains { $0.actorId == actorId } ?? false
        })
    }
    
    func cleanCaches() {
        for session in activeSessions {
            session.api.cleanCaches()
        }
    }
    
    static var main: AppState = .init()
}
