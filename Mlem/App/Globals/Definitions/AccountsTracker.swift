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
    
    var savedAccounts: [UserStub] = .init()
    var defaultAccount: UserStub? { savedAccounts.first }
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        self.savedAccounts = persistenceRepository.loadAccounts()
    }
    
    func addAccount(account: UserStub) {
        guard !savedAccounts.contains(where: { account.id == $0.id }) else {
            assertionFailure("Tried to add a duplicate account to the tracker")
            return
        }
        savedAccounts.append(account)
        saveAccounts()
    }

    func removeAccount(account: UserStub) {
        guard let index = savedAccounts.firstIndex(where: { account.id == $0.id }) else {
            assertionFailure("Tried to remove an account that does not exist")
            return
        }
        savedAccounts.remove(at: index)
        saveAccounts()
        account.deleteTokenFromKeychain()
        AppState.main.deactivate(userStub: account)
    }
    
    @discardableResult
    func login(
        client unauthenticatedApi: ApiClient,
        username: String,
        password: String,
        totpToken: String? = nil
    ) async throws -> UserStub {
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
        if let user = savedAccounts.first(where: {
            $0.name.caseInsensitiveCompare(username) == .orderedSame && $0.api.baseUrl == authenticatedApiClient.baseUrl
        }) {
            user.updateToken(token)
            return user
        } else {
            let user = try await authenticatedApiClient.loadUser()
            addAccount(account: user)
            return user
        }
    }
    
    func saveAccounts() {
        Task {
            try await self.persistenceRepository.saveAccounts(savedAccounts)
        }
    }
}
