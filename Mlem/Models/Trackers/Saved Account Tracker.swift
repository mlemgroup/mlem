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

    var defaultAccount: SavedAccount? {
        savedAccounts.first(where: { $0.id == defaultAccountId })
    }
    
    init() {
        _savedAccounts = .init(wrappedValue: SavedAccountTracker.loadAccounts())
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
}
