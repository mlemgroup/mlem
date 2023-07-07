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
    static let maxFeedPostHeight: CGFloat = 400
    static let largeAvatarSize: CGFloat = 32
    static let smallAvatarSize: CGFloat = 16
    static let defaultAvatarSize: CGFloat = 24
    static let largeAvatarSpacing: CGFloat = 10
    static let postAndCommentSpacing: CGFloat = 10
    static let largeItemCornerRadius: CGFloat = 8 // posts, website previews, etc
    static let smallItemCornerRadius: CGFloat = 4 // buttons, tags, compact thumbnails
    static let iconToTextSpacing: CGFloat = 2 // spacing between icons and text in info components
    
    // MARK: - SFSymbols
    // votes
    static let emptyUpvoteSymbolName: String = "arrow.up.square"
    static let fullUpvoteSymbolName: String = "arrow.up.square.fill"
    static let emptyDownvoteSymbolName: String = "arrow.down.square"
    static let fullDownvoteSymbolName: String = "arrow.down.square.fill"
    static let emptyResetVoteSymbolName: String = "minus.square"
    static let fullResetVoteSymbolName: String = "minus.square.fill"
    
    // reply
    static let emptyReplySymbolName: String = "arrowshape.turn.up.left"
    static let fullReplySymbolName: String = "arrowshape.turn.up.left.fill"
    
    // save
    static let emptySaveSymbolName: String = "bookmark"
    static let fullSaveSymbolName: String = "bookmark.fill"
    static let emptyUndoSaveSymbolName: String = "bookmark.slash"
    static let fullUndoSaveSymbolName: String = "bookmark.slash.fill"
    
    // mark read
    static let emptyMarkReadSymbolName: String = "envelope"
    static let fullMarkReadSymbolName: String = "envelope.open.fill"
    static let emptyMarkUnreadSymbolName: String = "envelope.open"
    static let fullMarkUnreadSymbolName: String = "envelope.fill"
    
    // MARK: - Other
    static let pictureEmoji: [String] = ["🎆", "🎇", "🌠", "🌅", "🌆", "🌁", "🌃", "🌄", "🌉", "🌌", "🌇", "🖼️", "🎑", "🏞️", "🗾", "🏙️"]
}
