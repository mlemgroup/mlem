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
        
        updateObserver = $savedAccounts.sink { [weak self] in
            self?.persistenceRepository.saveAccounts($0)
        }
    }
    
    func addAccount(account: SavedAccount) {
        // prevent dupes
        guard !savedAccounts.contains(account) else {
            return
        }
        
        savedAccounts.append(account)
        addAccountToInstanceMap(account: account)
    }
    
    // TODO: pass in AppState using a dependency or something nice like that
    func removeAccount(account: SavedAccount, appState: AppState, forceOnboard: () -> Void) {
        // remove from array
        savedAccounts = savedAccounts.filter { savedAccount in
            savedAccount != account
        }
        
        // remove from map
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
        
        // if another account exists, swap to it; otherwise force onboarding
        if let firstAccount: SavedAccount = savedAccounts.first {
            appState.setActiveAccount(firstAccount)
        } else {
            forceOnboard()
        }
    }
    
    // MARK: Helpers
    
    func addAccountToInstanceMap(account: SavedAccount) {
        let hostName = account.hostName ?? "Other"
        print("adding \(account.username) to \(hostName)")
        
        let instance = accountsByInstance[hostName] ?? []
        accountsByInstance[hostName] = instance + [account]
    }
}
