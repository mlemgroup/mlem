//
//  App Constants.swift
//  Mlem
//
//  Created by David Bureš on 03.05.2023.
//

import Foundation

struct AppConstants
{
    static let webSocketSession: URLSession = URLSession(configuration: .default)
    
    // MARK: - Files
    private static let applicationSupportDirectoryPath: URL = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    static let savedAccountsFilePath: URL = applicationSupportDirectoryPath.appendingPathComponent("Saved Accounts", conformingTo: .json)
    static let filteredKeywordsFilePath: URL = applicationSupportDirectoryPath.appendingPathComponent("Blocked Keywords", conformingTo: .json)
    static let favoriteCommunitiesFilePath: URL = applicationSupportDirectoryPath.appendingPathComponent("Favorite Communities", conformingTo: .json)
}
