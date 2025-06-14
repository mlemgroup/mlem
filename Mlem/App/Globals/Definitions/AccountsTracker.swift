//
//  AccountsTracker.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Combine
import Dependencies
import Foundation
import MlemMiddleware
import Observation

private let defaultInstanceGroupKey = "Other"

@Observable
class AccountsTracker {
    enum SaveType {
        case user, guest, all
    }
    
    static let main: AccountsTracker = .init()
    
    @ObservationIgnored @Dependency(\.persistenceRepository) private var persistenceRepository
    
    var userAccounts: [UserAccount] = .init()
    var guestAccounts: [GuestAccount] = .init()
    
    var allAccounts: [any Account] { userAccounts + guestAccounts }
    
    // Used on startup to determine which account should be made active
    func mostRecentAccount() -> any Account {
        let allAccounts: [any Account] = userAccounts + guestAccounts
        if let activeAccount = allAccounts.first(where: { $0.activityState == .active }) {
            return activeAccount
        }
        let sorted = allAccounts.sorted(by: { $0.activityState.lastUsed ?? .distantPast < $1.activityState.lastUsed ?? .distantPast })
        if let lastUsedAccount = sorted.last {
            return lastUsedAccount
        }
        return userAccounts.first ?? defaultGuestAccount
    }
    
    var defaultGuestAccount: GuestAccount {
        // This will never fail because we're passing a literal URL that is known to always succeed
        // swiftlint:disable:next force_try
        try! GuestAccount.getGuestAccount(url: URL(string: "https://lemmy.world/")!)
    }
    
    var isEmpty: Bool { userAccounts.isEmpty && guestAccounts.isEmpty }
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        self.userAccounts = persistenceRepository.loadUserAccounts()
        self.guestAccounts = persistenceRepository.loadGuestAccounts()
    }
    
    func addAccount(account: any Account) {
        if let account = account as? UserAccount {
            guard !userAccounts.contains(where: { $0 === account }) else {
                assertionFailure("Tried to add a duplicate account to the tracker")
                return
            }
            userAccounts.append(account)
            saveAccounts(ofType: .user)
        } else if let account = account as? GuestAccount {
            guard !guestAccounts.contains(where: { $0 === account }) else {
                assertionFailure("Tried to add a duplicate account to the tracker")
                return
            }
            guestAccounts.append(account)
            saveAccounts(ofType: .guest)
        } else {
            assertionFailure()
        }
    }
    
    func removeAccount(account: any Account) {
        if let account = account as? UserAccount {
            guard let index = userAccounts.firstIndex(where: { $0 === account }) else {
                assertionFailure("Tried to remove an account that does not exist")
                return
            }
            userAccounts.remove(at: index)
            saveAccounts(ofType: .user)
            account.deleteTokenFromKeychain()
        } else if let account = account as? GuestAccount {
            guard let index = guestAccounts.firstIndex(where: { $0 === account }) else {
                assertionFailure("Tried to remove an account that does not exist")
                return
            }
            guestAccounts.remove(at: index)
            account.resetStoredSettings(withSave: false)
            saveAccounts(ofType: .guest)
        } else {
            assertionFailure()
        }
        AppState.main.deactivate(account: account)
        do {
            try PersistenceRepository.liveValue.deleteAccountSettings(for: account)
        } catch {
            handleError(error)
        }
        GuestAccountCache.main.clean()
    }
    
    @discardableResult
    func logIn(
        client unauthenticatedApi: ApiClient,
        usernameOrEmail: String,
        password: String,
        totpToken: String? = nil
    ) async throws -> UserAccount {
        let token = try await unauthenticatedApi.getAccountToken(
            usernameOrEmail: usernameOrEmail,
            password: password,
            totpToken: totpToken
        )
        let username = try await unauthenticatedApi.getUsernameFromToken(token: token)
        
        return try await logIn(
            username: username,
            url: unauthenticatedApi.baseUrl,
            token: token
        )
    }
    
    @discardableResult
    func logIn(
        username: String,
        url: URL,
        token: String
    ) async throws -> UserAccount {
        let authenticatedApiClient = ApiClient.getApiClient(url: url, username: username)
        authenticatedApiClient.updateToken(token)
        
        // Check if account exists already
        if let account = userAccounts.first(where: {
            $0.name.caseInsensitiveCompare(username) == .orderedSame && $0.api.baseUrl == url
        }) {
            account.updateToken(token)
            saveAccounts(ofType: .user)
            return account
        } else {
            let response = try await authenticatedApiClient.getMyPerson()
            guard let person = response.person else {
                throw ApiClientError.unsuccessful
            }
            let account = UserAccount(person: person, instance: response.instance)
            addAccount(account: account)
            return account
        }
    }
    
    func saveAccounts(ofType type: SaveType) {
        Task {
            if type != .guest {
                try await self.persistenceRepository.saveUserAccounts(userAccounts)
            }
            if type != .user {
                try await self.persistenceRepository.saveGuestAccounts(guestAccounts)
            }
        }
    }
    
    var highestLevelAccountType: AccountType {
        userAccounts.lazy.map(\.accountType).max() ?? .guest
    }
}
