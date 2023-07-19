//
//  Saved Community Tracker.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation
import SwiftUI

class SavedAccountTracker: ObservableObject {
    
    @AppStorage("defaultAccountId") var defaultAccountId: Int?
    
    @Published var savedAccounts: [SavedAccount]
    @Published var accountsByInstance: [String: [SavedAccount]]

    var defaultAccount: SavedAccount? {
        savedAccounts.first(where: { $0.id == defaultAccountId })
    }
    
    init() {
        _savedAccounts = .init(wrappedValue: SavedAccountTracker.loadAccounts())
        
        accountsByInstance = [:]
        savedAccounts.forEach { account in
            addAccountToInstanceMap(account: account)
        }
    }
    
    func addAccount(account: SavedAccount) {
        savedAccounts.append(account)
        addAccountToInstanceMap(account: account)
    }
    
    func removeAccount(account: SavedAccount) {
        // remove from array--do this second to force update
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
    }

    static func loadAccounts() -> [SavedAccount] {
        if FileManager.default.fileExists(atPath: AppConstants.savedAccountsFilePath.path) {
            print("Saved Accounts file exists, will attempt to load saved accounts")
            do {
                let loadedUpAccounts = try decodeFromFile(
                    fromURL: AppConstants.savedAccountsFilePath,
                    whatToDecode: .accounts
                ) as? [SavedAccount] ?? []

                // MARK: - Associate the accounts with their secret credentials

                if !loadedUpAccounts.isEmpty {

                    let accounts = loadedUpAccounts.compactMap { account -> SavedAccount? in
                        guard let token = AppConstants.keychain["\(account.id)_accessToken"] else {
                            return nil
                        }

                        return SavedAccount(
                            id: account.id,
                            instanceLink: account.instanceLink,
                            accessToken: token,
                            username: account.username
                        )
                    }

                    return accounts
                }
            } catch let savedAccountDecodingError {
                print("Failed while decoding saved accounts: \(savedAccountDecodingError)")
            }
        } else {
            print("Saved Accounts file does not exist, will try to create it")

            do {
                try createEmptyFile(at: AppConstants.savedAccountsFilePath)
            } catch let emptyFileCreationError {
                print("Failed while creating an empty file: \(emptyFileCreationError)")
            }
        }

        return []
    }

    func saveToDisk() {
        do {
            let encodedSavedAccounts: Data = try encodeForSaving(object: self.savedAccounts)

            do {
                try writeDataToFile(data: encodedSavedAccounts, fileURL: AppConstants.savedAccountsFilePath)
            } catch let writingError {
                print("Failed while saving data to file: \(writingError)")
            }
        } catch let encodingError {
            print("Failed while encoding accounts to data: \(encodingError)")
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
