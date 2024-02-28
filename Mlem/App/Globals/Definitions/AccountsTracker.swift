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

@Observable
class AccountsTracker {
    @ObservationIgnored @Dependency(\.persistenceRepository) private var persistenceRepository
    @ObservationIgnored @AppStorage("defaultAccountId") var defaultAccountId: Int?
    
    var savedAccounts: [UserStub] = .init()
    
    var defaultAccount: UserStub? {
        savedAccounts.first(where: { $0.id == defaultAccountId })
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.savedAccounts = persistenceRepository.loadAccounts()
    }
    
    func addAccount(account: UserStub) {
        guard !savedAccounts.contains(where: { account.id == $0.id }) else {
            assertionFailure("Tried to add a duplicate account to the tracker")
            return
        }
        savedAccounts.append(account)
    }

    func removeAccount(account: UserStub) {
        guard let index = savedAccounts.firstIndex(where: { account.id == $0.id }) else {
            assertionFailure("Tried to remove an account that does not exist")
            return
        }
        savedAccounts.remove(at: index)
        saveAccounts()
    }
    
    func saveAccounts() {
        Task {
            try await self.persistenceRepository.saveAccounts(savedAccounts)
        }
    }
}
