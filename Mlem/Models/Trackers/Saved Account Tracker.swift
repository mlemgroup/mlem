//
//  Saved Community Tracker.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Combine
import Dependencies
import Foundation
import SwiftUI

@MainActor
class SavedAccountTracker: ObservableObject {
    @Dependency(\.persistenceRepository) private var persistenceRepository
    
    @AppStorage("defaultAccountId") var defaultAccountId: Int?
    
    @Published var savedAccounts = [SavedAccount]()
    @Published var accountsByInstance = [String: [SavedAccount]]()

    var defaultAccount: SavedAccount? {
        savedAccounts.first(where: { $0.id == defaultAccountId })
    }
    
    private var updateObserver: AnyCancellable?
    
    init() {
        _savedAccounts = .init(wrappedValue: persistenceRepository.loadAccounts())
        savedAccounts.forEach { account in
            addAccountToInstanceMap(account: account)
        }
        
        self.updateObserver = $savedAccounts.sink { [weak self] value in
            Task {
                try await self?.persistenceRepository.saveAccounts(value)
            }
        }
    }
    
    func addAccount(account: SavedAccount) {
        print("Adding account: \(account.username) (\(account.nickname))")
        // prevent dupes
        guard !savedAccounts.contains(account) else {
            print("dupe!")
            return
        }
        
        savedAccounts.append(account)
        addAccountToInstanceMap(account: account)
    }
    
    /**
     Replaces an account with another equivalent account. Useful for changing non-identifying properties.
     */
    func replaceAccount(account: SavedAccount) {
        // ensure present
        guard savedAccounts.contains(account) else {
            assertionFailure("Tried to replace account that does not exist")
            return
        }
        
        // replace in data structures
        replaceAccountInArray(account: account)
        replaceAccountInInstanceMap(account: account)
    }
    
    // TODO: pass in AppState using a dependency or something nice like that
    func removeAccount(account: SavedAccount, appState: AppState, forceOnboard: () -> Void) {
        // remove from data structures
        removeAccountFromArray(account: account)
        removeAccountFromInstanceMap(account: account)
        
        // if another account exists, swap to it; otherwise force onboarding
        if let firstAccount: SavedAccount = savedAccounts.first {
            appState.setActiveAccount(firstAccount)
        } else {
            forceOnboard()
        }
    }
    
    // MARK: Helpers
    
    func removeAccountFromArray(account: SavedAccount) {
        savedAccounts = savedAccounts.filter { savedAccount in
            savedAccount != account
        }
    }
    
    func replaceAccountInArray(account: SavedAccount) {
        if let idx = savedAccounts.firstIndex(of: account) {
            savedAccounts[idx] = account
        }
    }
    
    func addAccountToInstanceMap(account: SavedAccount) {
        let hostName = account.hostName ?? "Other"
        
        let instance = accountsByInstance[hostName] ?? []
        accountsByInstance[hostName] = instance + [account]
    }
    
    func replaceAccountInInstanceMap(account: SavedAccount) {
        let hostName = account.hostName ?? "Other"
        if var instance = accountsByInstance[hostName], let idx = instance.firstIndex(of: account) {
            instance[idx] = account
        }
    }
    
    func removeAccountFromInstanceMap(account: SavedAccount) {
        let hostName = account.hostName ?? "Other"
        if let instance = accountsByInstance[hostName] {
            let filteredAccounts = instance.filter { savedAccount in
                savedAccount != account
            }
            
            // delete key if no accounts associated, otherwise just remove accounts
            if filteredAccounts.isEmpty {
                accountsByInstance.removeValue(forKey: hostName)
            } else {
                accountsByInstance[hostName] = filteredAccounts
            }
        }
    }
}
