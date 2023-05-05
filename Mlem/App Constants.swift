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
    static let savedCommunitiesFilePath: URL = applicationSupportDirectoryPath.appendingPathComponent("Saved Communities", conformingTo: .json)
}
