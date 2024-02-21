//
//  AccountsTracker.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Combine
import Dependencies
import Foundation
import SwiftUI

private let defaultInstanceGroupKey = "Other"

class AccountsTracker: ObservableObject {
    @Dependency(\.persistenceRepository) private var persistenceRepository
    
    @Environment(\.setAppFlow) private var setFlow
    
    @AppStorage("defaultAccountId") var defaultAccountId: Int?
    
    @Published var savedAccounts = [SavedAccount]()
    
    var defaultAccount: SavedAccount? {
        savedAccounts.first(where: { $0.id == defaultAccountId })
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialisation
    
    init() {
        _savedAccounts = .init(wrappedValue: persistenceRepository.loadAccounts())
        // observe our saved accounts and trigger internal updates when they change
        $savedAccounts
            .sink { [weak self] in self?.accountsDidChange($0) }
            .store(in: &cancellables)
    }
    
    // MARK: - Public methods
    
    func addAccount(account: SavedAccount) {
        guard !savedAccounts.contains(account) else {
            assertionFailure("Tried to add a duplicate account to the tracker")
            return
        }
        
        savedAccounts.append(account)
    }
    
    /// Replaces an account with another equivalent account. Useful for changing non-identifying properties.
    /// - Parameter account: an updated `SavedAccount`
    func update(with account: SavedAccount) {
        guard let index = savedAccounts.firstIndex(of: account) else {
            assertionFailure("Tried to update an account that does not exist")
            return
        }
        
        savedAccounts[index] = account
    }
    
    func removeAccount(account: SavedAccount) {
        guard let index = savedAccounts.firstIndex(of: account) else {
            assertionFailure("Tried to remove an account that does not exist")
            return
        }
        
        savedAccounts.remove(at: index)
    }
    
    // MARK: - Private methods
    
    private func accountsDidChange(_ newValue: [SavedAccount]) {
        Task {
            try await self.persistenceRepository.saveAccounts(newValue)
        }
    }
}
