//
//  App Constants.swift
//  Mlem
//
//  Created by David Bureš on 03.05.2023.
//

import Foundation
import SafariServices
import KeychainAccess

struct AppConstants
{
    static let webSocketSession: URLSession = URLSession(configuration: .default)
    
    // MARK: - Date parsing
    static let dateFormatter: DateFormatter = DateFormatter()
    static let relativeDateFormatter: RelativeDateTimeFormatter = RelativeDateTimeFormatter()
    
    // MARK: - Keychain
    static let keychain: Keychain = Keychain(service: "com.davidbures.Mlem-keychain")
    
    // MARK: - In-app Safari
    static let inAppSafariConfiguration: SFSafariViewController.Configuration =
    {
        let configuration = SFSafariViewController.Configuration()
        configuration.barCollapsingEnabled = true
        configuration.entersReaderIfAvailable = false
        
        return configuration
    }()
    
    // MARK: - Files
    private static let applicationSupportDirectoryPath: URL = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    static let savedAccountsFilePath: URL = applicationSupportDirectoryPath.appendingPathComponent("Saved Accounts", conformingTo: .json)
    static let filteredKeywordsFilePath: URL = applicationSupportDirectoryPath.appendingPathComponent("Blocked Keywords", conformingTo: .json)
    static let favoriteCommunitiesFilePath: URL = applicationSupportDirectoryPath.appendingPathComponent("Favorite Communities", conformingTo: .json)
}
