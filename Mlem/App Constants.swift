//
//  App Constants.swift
//  Mlem
//
//  Created by David Bureš on 03.05.2023.
//

import Foundation
import KeychainAccess
import UIKit

struct AppConstants {
    static let cacheSize = 500_000_000 // 500MiB in bytes
    static let urlCache: URLCache = URLCache(memoryCapacity: cacheSize, diskCapacity: cacheSize)
    static let webSocketSession: URLSession = URLSession(configuration: .default)
    static let urlSession: URLSession = URLSession(configuration: .default)

    // MARK: - Date parsing
    static let dateFormatter: DateFormatter = DateFormatter()
    static let relativeDateFormatter: RelativeDateTimeFormatter = RelativeDateTimeFormatter()

    // MARK: - Keychain
    static let keychain: Keychain = Keychain(service: "com.davidbures.Mlem-keychain")

    // MARK: - Files
    private static let applicationSupportDirectoryPath = {
        guard let path = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            fatalError("unable to access application support path")
        }

        return path
    }()

    static let savedAccountsFilePath = { applicationSupportDirectoryPath
        .appendingPathComponent("Saved Accounts", conformingTo: .json)
    }()

    static let filteredKeywordsFilePath = { applicationSupportDirectoryPath
        .appendingPathComponent("Blocked Keywords", conformingTo: .json)
    }()

    static let favoriteCommunitiesFilePath = { applicationSupportDirectoryPath
        .appendingPathComponent("Favorite Communities", conformingTo: .json)
    }()

    // MARK: - Haptics
    static let hapticManager: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator()

    // MARK: - DragGesture thresholds
    static let longSwipeDragMin: CGFloat = 150
    static let shortSwipeDragMin: CGFloat = 60
    
    // MARK: - Sizes
    static let largeAvatarSize: CGFloat = 32
    static let defaultAvatarSize: CGFloat = 24
    static let largeAvatarSpacing: CGFloat = 10
}
