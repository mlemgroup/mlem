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
import SwiftUI

private let defaultInstanceGroupKey = "Other"

@Observable
class AccountsTracker {
    static let main: AccountsTracker = .init()
    
    @ObservationIgnored @Dependency(\.persistenceRepository) private var persistenceRepository
    
    var savedAccounts: [UserAccount] = .init()
    var defaultAccount: UserAccount? { savedAccounts.first }
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        self.savedAccounts = persistenceRepository.loadAccounts()
    }
    
    func addAccount(account: UserAccount) {
        guard !savedAccounts.contains(where: { account.id == $0.id }) else {
            assertionFailure("Tried to add a duplicate account to the tracker")
            return
        }
        savedAccounts.append(account)
        saveAccounts()
    }

    func removeAccount(account: any Account) {
        guard let account = account as? UserAccount else { return }
        guard let index = savedAccounts.firstIndex(where: { account.id == $0.id }) else {
            assertionFailure("Tried to remove an account that does not exist")
            return
        }
        savedAccounts.remove(at: index)
        saveAccounts()
        account.deleteTokenFromKeychain()
        AppState.main.deactivate(account: account)
    }
    
    @discardableResult
    func login(
        client unauthenticatedApi: ApiClient,
        username: String,
        password: String,
        totpToken: String? = nil
    ) async throws -> UserAccount {
        let response = try await unauthenticatedApi.login(
            username: username,
            password: password,
            totpToken: totpToken
        )
        guard let token = response.jwt else {
            throw ApiClientError.invalidSession
        }

        let authenticatedApiClient = ApiClient.getApiClient(for: unauthenticatedApi.baseUrl, with: token)
        
        // Check if account exists already
        if let account = savedAccounts.first(where: {
            $0.name.caseInsensitiveCompare(username) == .orderedSame && $0.api.baseUrl == authenticatedApiClient.baseUrl
        }) {
            account.updateToken(token)
            return account
        } else {
            let response = try await authenticatedApiClient.getMyPerson()
            guard let person = response.person else {
                throw ApiClientError.invalidSession
            }
            let account = UserAccount(person: person, instance: response.instance)
            addAccount(account: account)
            return account
        }
    }
    
    func saveAccounts() {
        Task {
            try await self.persistenceRepository.saveAccounts(savedAccounts)
        }
    }
}
