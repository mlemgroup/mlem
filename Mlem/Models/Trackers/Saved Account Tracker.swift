//
//  SavedAccountTracker.swift
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
class SavedAccountTracker {
    @Dependency(\.persistenceRepository) private var persistenceRepository
    
    @AppStorage("defaultAccountId") var defaultAccountId: Int?
    
    var savedAccounts = [AuthenticatedUserStub]()
    
    var defaultAccount: AuthenticatedUserStub? {
        savedAccounts.first(where: { $0.id == defaultAccountId })
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        savedAccounts = persistenceRepository.loadAccounts()
    }
    
    func addAccount(account: AuthenticatedUserStub) {
        guard !savedAccounts.contains(where: { account.id == $0.id }) else {
            assertionFailure("Tried to add a duplicate account to the tracker")
            return
        }
        savedAccounts.append(account)
    }

    func removeAccount(account: AuthenticatedUserStub) {
        guard let index = savedAccounts.firstIndex(where: { account.id == $0.id }) else {
            assertionFailure("Tried to remove an account that does not exist")
            return
        }
        savedAccounts.remove(at: index)
    }
    
    func saveAccounts() {
        try await self.persistenceRepository.saveAccounts(savedAccounts)
    }
}
