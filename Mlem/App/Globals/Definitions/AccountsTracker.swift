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
    var defaultAccount: any Account { userAccounts.first ?? defaultGuestAccount }
    var defaultGuestAccount: GuestAccount {
        // This will never fail because we're passing a literal URL that is known to always succeed
        // swiftlint:disable:next force_try
        try! (guestAccounts.first ?? .getGuestAccount(url: URL(string: "https://lemmy.world/")!))
    }
    
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
        GuestAccountCache.main.clean()
    }
    
    @discardableResult
    func logIn(
        client unauthenticatedApi: ApiClient,
        username: String,
        password: String,
        totpToken: String? = nil
    ) async throws -> UserAccount {
        let response = try await unauthenticatedApi.logIn(
            username: username,
            password: password,
            totpToken: totpToken
        )
        guard let token = response.jwt else {
            throw ApiClientError.unsuccessful
        }
        
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
        let authenticatedApiClient = ApiClient.getApiClient(for: url, with: token)
        
        // Check if account exists already
        if let account = userAccounts.first(where: {
            $0.name.caseInsensitiveCompare(username) == .orderedSame && $0.api.baseUrl == url
        }) {
            account.updateToken(token)
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
}
