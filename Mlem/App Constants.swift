//
//  App Constants.swift
//  Mlem
//
//  Created by David Bureš on 03.05.2023.
//

import Foundation
import SafariServices

struct AppConstants
{
    static let webSocketSession: URLSession = URLSession(configuration: .default)
    
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
