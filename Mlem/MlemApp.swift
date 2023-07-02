//
//  MlemApp.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

@main
struct MlemApp: App {
    @AppStorage("lightOrDarkMode") var lightOrDarkMode: UIUserInterfaceStyle = .unspecified

    @StateObject var accountsTracker: SavedAccountTracker = .init()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            Window()
                .environmentObject(accountsTracker)
                .onAppear {
                    URLCache.shared = AppConstants.urlCache
                    loadAccounts()

                    setupAppShortcuts()

                    // set app theme to user preference
                    let windowScene =  UIApplication.shared.connectedScenes.first as? UIWindowScene
                    windowScene?.windows.first?.overrideUserInterfaceStyle = lightOrDarkMode
                }
        }
        .onChange(of: accountsTracker.savedAccounts) { newValue in
            do {
                let encodedSavedAccounts: Data = try encodeForSaving(object: newValue)

                do {
                    try writeDataToFile(data: encodedSavedAccounts, fileURL: AppConstants.savedAccountsFilePath)
                } catch let writingError {
                    print("Failed while saving data to file: \(writingError)")
                }
            } catch let encodingError {
                print("Failed while encoding accounts to data: \(encodingError)")
            }
        }
        .onChange(of: lightOrDarkMode) { value in
            let windowScene =  UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.windows.first?.overrideUserInterfaceStyle = value
        }
    }

    func loadAccounts() {
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

                    accountsTracker.savedAccounts = accounts
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
    }

    func setupAppShortcuts() {
        guard accountsTracker.savedAccounts.first != nil else { return }

        // Subscribed Feed
        let loveIcon = UIApplicationShortcutIcon(type: .love)
        let subscribedFeedItem = UIApplicationShortcutItem(
            type: FeedType.subscribed.rawValue,
            localizedTitle: "Subscribed",
            localizedSubtitle: nil,
            icon: loveIcon,
            userInfo: nil
        )

        // Local Feed
        let homeIcon = UIApplicationShortcutIcon(type: .home)
        let localFeedItem = UIApplicationShortcutItem(
            type: FeedType.local.rawValue,
            localizedTitle: "Local",
            localizedSubtitle: nil,
            icon: homeIcon,
            userInfo: nil
        )

        // All Feed
        let cloudIcon = UIApplicationShortcutIcon(type: .cloud)
        let allFeedItem = UIApplicationShortcutItem(
            type: FeedType.all.rawValue,
            localizedTitle: "All",
            localizedSubtitle: nil,
            icon: cloudIcon,
            userInfo: nil
        )

        UIApplication.shared.shortcutItems = [
            subscribedFeedItem,
            localFeedItem,
            allFeedItem
        ]
    }
}
