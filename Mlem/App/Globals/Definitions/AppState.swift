//
//  AppState.swift
//  Mlem
//
//  Created by Sjmarf on 17/02/2024.
//

import Dependencies
import Foundation
import MlemMiddleware
import Observation

@Observable
class AppState {
    private(set) var guestSession: GuestSession!
    private(set) var activeSessions: [UserSession] = []
    
    private init() {
        self.guestSession = .init(account: AccountsTracker.main.defaultGuestAccount)
        changeAccount(to: AccountsTracker.main.defaultAccount, deactivateOldGuest: false)
    }
    
    func changeAccount(to account: any Account) {
        changeAccount(to: account, deactivateOldGuest: true)
    }
    
    private func changeAccount(to account: any Account, deactivateOldGuest: Bool) {
        ToastModel.main.add(.account(account))
        
        activeSessions.forEach { $0.deactivate() }
        if deactivateOldGuest {
            guestSession?.deactivate()
        }
        
        // Save because we updated `lastUsed` in the above `deactivate()` calls
        AccountsTracker.main.saveAccounts(ofType: .all)
        
        if let account = account as? UserAccount {
            let activeAccount = UserSession(account: account)
            activeSessions = [activeAccount]
        } else if let account = account as? GuestAccount {
            activeSessions = []
            guestSession = .init(account: account)
            GuestAccountCache.main.clean()
        } else {
            assertionFailure()
        }
    }
    
    func deactivate(account: any Account) {
        if let account = account as? UserAccount {
            if let index = AppState.main.activeSessions.firstIndex(where: { $0.account === account }) {
                activeSessions[index].deactivate()
                activeSessions.remove(at: index)
            }
        } else if let account = account as? GuestAccount {
            guard account == guestSession.account else {
                assertionFailure("Tried to deactivate a non-active GuestAccount")
                return
            }
            guestSession = .init(account: AccountsTracker.main.defaultGuestAccount)
            GuestAccountCache.main.clean()
        }
        changeAccount(to: AccountsTracker.main.defaultAccount)
        AccountsTracker.main.saveAccounts(ofType: .all)
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
