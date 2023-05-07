//
//  MlemApp.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI
import SwiftyJSON

@main
struct MlemApp: App
{
    @StateObject var appState: AppState = .init()
    @StateObject var accountsTracker: SavedAccountTracker = .init()

    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
                .environmentObject(appState)
                .environmentObject(accountsTracker)
                .onChange(of: accountsTracker.savedAccounts)
                { newValue in
                    do
                    {
                        let encodedSavedAccounts: Data = try encodeForSaving(object: newValue)

                        do
                        {
                            try writeDataToFile(data: encodedSavedAccounts, fileURL: AppConstants.savedAccountsFilePath)
                        }
                        catch let writingError
                        {
                            print("Failed while saving data to file: \(writingError)")
                        }
                    }
                    catch let encodingError
                    {
                        print("Failed while encoding communities to data: \(encodingError)")
                    }
                }
                .onAppear
                {
                    if FileManager.default.fileExists(atPath: AppConstants.savedAccountsFilePath.path)
                    {
                        print("Saved Accounts file exists, will attempt to load saved accounts")
                        
                        do
                        {
                            accountsTracker.savedAccounts = try decodeCommunitiesFromFile(fromURL: AppConstants.savedAccountsFilePath)
                        }
                        catch let savedAccountDecodingError
                        {
                            print("Failed while decoding saved accounts: \(savedAccountDecodingError)")
                        }
                    }
                    else
                    {
                        print("Saved Accounts file does not exist, will try to create it")
                        
                        do
                        {
                            try createEmptyFile(at: AppConstants.savedAccountsFilePath)
                        }
                        catch let emptyFileCreationError
                        {
                            print("Failed while creating an empty file: \(emptyFileCreationError)")
                        }
                    }
                }
        }
    }
}
