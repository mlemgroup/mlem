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
    @ObservationIgnored @Namespace var namespace

    private(set) var guestSession: GuestSession! {
        didSet {
            if oldValue != guestSession {
                oldValue?.deactivate()
            }
        }
    }
    
    private(set) var activeSessions: [UserSession] = [] {
        didSet {
            if oldValue != activeSessions {
                for session in Set(oldValue).subtracting(activeSessions) {
                    session.deactivate()
                }
            }
        }
    }
    
    var contentViewTab: ContentView.Tab = .feeds
    
    /// ``ContentView`` watches this for changes. When it is toggled, the app is refreshed.
    var appRefreshToggle: Bool = true
    
    private init() {
        self.guestSession = .init(account: AccountsTracker.main.defaultGuestAccount)
        setAccount(to: AccountsTracker.main.mostRecentAccount())
    }
  
    // TODO: updated mocks
//    #if DEBUG
//        private init(api: MockApiClient) {
//            self.guestSession = .init(account: .mock(api: api))
//        }
//    
//        static func mock(api: MockApiClient) -> AppState { .init(api: api) }
//    #endif
    
    /// If `keepPlace` is `nil`, use the value from `UserDefaults`.
    func changeAccount(to account: any Account, keepPlace: Bool? = nil, showAvatarPopup: Bool = true) {
        @Setting(\.accounts_keepPlace) var keepPlaceSetting
        let keepPlace = keepPlace ?? keepPlaceSetting
        
        if firstAccount is UserAccount {
            Task {
                do {
                    try await firstAccount.api.flushPostReadQueue()
                } catch {
                    handleError(error)
                }
            }
        }
        
        if keepPlace {
            if showAvatarPopup {
                ToastModel.main.add(.account(account))
            }
            setAccount(to: account)
        } else {
            transition(account)
            // The delays between these events are necessary to stop SwiftUIIntrospect from causing a lag spike.
            // That library seems to not like us adding subviews to the window directly. For some reason adding
            // these delays fixes that.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.appRefreshToggle = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.setAccount(to: account)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.appRefreshToggle = true
            }
        }
    }
    
    private func setAccount(to account: any Account) {
        // Save because we updated `lastUsed` in the above `deactivate()` calls
        AccountsTracker.main.saveAccounts(ofType: .all)
        
        if let account = account as? UserAccount {
            let activeAccount = UserSession(account: account)
            if activeSessions.isEmpty {
                guestSession.deactivate()
            }
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
            } else { return }
        } else if let account = account as? GuestAccount {
            guard account == guestSession.account else { return }
            guestSession = .init(account: AccountsTracker.main.defaultGuestAccount)
        }
        changeAccount(to: AccountsTracker.main.mostRecentAccount())
    }
    
    var firstSession: any Session { activeSessions.first ?? guestSession }
    var firstAccount: any Account { firstSession.account }
    var firstApi: ApiClient { firstSession.api }
    var firstPerson: Person? { (firstSession as? UserSession)?.person }
    
    var isModOrAdmin: Bool {
        firstApi.isAdmin || !(firstPerson?.moderatedCommunities.value?.isEmpty ?? true)
    }
    
    func accountThatModerates(actorId: ActorIdentifier) -> UserSession? {
        activeSessions.first(where: { session in
            session.person?.moderatedCommunities.value_?.contains { $0.actorId == actorId } ?? false
        })
    }
    
    func cleanCaches() {
        for session in activeSessions {
            session.api.cleanCaches()
        }
    }
    
    func switchToMostRecentAccount() -> Bool {
        let mostRecentAccount = AccountsTracker.main.allAccounts
            .filter { $0.actorId != firstAccount.actorId }
            .min { ($0.activityState.lastUsed ?? .distantPast) > ($1.activityState.lastUsed ?? .distantPast) }
            
        guard let mostRecentAccount else { return false }
        
        changeAccount(to: mostRecentAccount)
        return true
    }
    
    var initialFeedSortType: PostSortType {
        get async throws {
            // In future, we should be storing `PostSortType` in `Settings` rather than `LemmySortType`
            let defaultSort: PostSortType = .init(Settings.get(\.post_defaultSort))
            if try await firstApi.supports(.postSortType(defaultSort)) { return defaultSort }
            return .init(Settings.get(\.post_fallbackSort))
        }
    }
    
    static var main: AppState = .init()
}
