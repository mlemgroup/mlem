//
//  App Constants.swift
//  Mlem
//
//  Created by David Bureš on 03.05.2023.
//

import Foundation
import KeychainAccess

enum AppConstants {
    static let cacheSize = 500_000_000 // 500MB in bytes
    static let urlCache: URLCache = .init(memoryCapacity: cacheSize, diskCapacity: cacheSize)
    static let imageSizeCache: NSCache<NSString, ImageSize> = .init()
    static let webSocketSession: URLSession = .init(configuration: .default)
    static let urlSession: URLSession = .init(configuration: .default)

    // MARK: - Date parsing

    static let dateComponentsFormatter: DateComponentsFormatter = .init()

    // MARK: - Keychain

    static let keychain: Keychain = .init(service: "com.hanners.Mlem-keychain")
    
    // MARK: - Text Fields

    static let textFieldVariableLineLimit: ClosedRange<Int> = 1 ... 10
    
    // MARK: - Sizes

    static let maxFeedPostHeight: CGFloat = 400
    static let maxFeedPostHeightExpanded: CGFloat = 3000
    static let appIconSize: CGFloat = 60
    static let thumbnailSize: CGFloat = 60
    static let hugeAvatarSize: CGFloat = 120
    static let largeAvatarSize: CGFloat = 32
    static let smallAvatarSize: CGFloat = 16
    static let defaultAvatarSize: CGFloat = 24
    static let largeAvatarSpacing: CGFloat = 10
    static let doubleSpacing: CGFloat = 20
    static let standardSpacing: CGFloat = 10 // standard spacing for the app
    static let halfSpacing: CGFloat = 5
    @available(*, deprecated, message: "prefer standardSpacing")
    static let postAndCommentSpacing: CGFloat = 10
    static let compactSpacing: CGFloat = 6 // standard spacing for compact things
    static let appIconCornerRadius: CGFloat = 14
    static let largeItemCornerRadius: CGFloat = 8 // posts, website previews, etc
    static let smallItemCornerRadius: CGFloat = 6 // settings items, compact thumbnails
    static let tinyItemCornerRadius: CGFloat = 4 // buttons
    static let iconToTextSpacing: CGFloat = 2 // spacing between icons and text in info components
    // NOTE: barIconHitbox = (barIconSize + 2 * barIconPadding) + (2 * postAndCommentSpacing)
    static let barIconSize: CGFloat = 15.5 // square size of a bar button
    static let barIconPadding: CGFloat = 4.25 // padding for bar button
    static let barIconHitbox: CGFloat = 44 // Apple HIG guidelines
    static let settingsIconSize: CGFloat = 28
    static let fancyTabBarHeight: CGFloat = 48 // total height of the fancy tab bar
    static let editorOverscroll: CGFloat = 30
    static let expandedPostOverscroll: CGFloat = 80
    
    // MARK: - Other

    static let pictureEmoji: [String] = ["🎆", "🎇", "🌠", "🌅", "🌆", "🌁", "🌃", "🌄", "🌉", "🌌", "🌇", "🖼️", "🎑", "🏞️", "🗾", "🏙️"]
    static let infiniteLoadThresholdOffset: Int = -10
    
    // MARK: - Text

    static let blockUserPrompt: String = "Really block this user?"
    static let blockCommunityPrompt: String = "Really block this community?"
    static let blockInstancePrompt: String = "Really block this instance?"
}
