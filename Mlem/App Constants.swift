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
    static let cacheSize = 500_000_000 // 500MB in bytes
    static let urlCache: URLCache = .init(memoryCapacity: cacheSize, diskCapacity: cacheSize)
    static let imageSizeCache: NSCache<NSString, ImageSize> = .init()
    static let webSocketSession: URLSession = .init(configuration: .default)
    static let urlSession: URLSession = .init(configuration: .default)

    // MARK: - Date parsing

    static let dateComponentsFormatter: DateComponentsFormatter = .init()

    // MARK: - Keychain

    static let keychain: Keychain = .init(service: "com.hanners.Mlem-keychain")

    // MARK: - DragGesture thresholds

    static let longSwipeDragMin: CGFloat = 150
    static let shortSwipeDragMin: CGFloat = 60
    
    // MARK: - Text Fields
    static let textFieldVariableLineLimit: ClosedRange<Int> = 1...10
    
    // MARK: - Sizes

    static let maxFeedPostHeight: CGFloat = 400
    static let maxFeedPostHeightExpanded: CGFloat = 3000
    static let thumbnailSize: CGFloat = 60
    static let hugeAvatarSize: CGFloat = 120
    static let largeAvatarSize: CGFloat = 32
    static let smallAvatarSize: CGFloat = 16
    static let defaultAvatarSize: CGFloat = 24
    static let largeAvatarSpacing: CGFloat = 10
    static let postAndCommentSpacing: CGFloat = 10 // standard spacing for the app
    static let compactSpacing: CGFloat = 6 // standard spacing for compact things
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
    
    // MARK: - SFSymbols

    // votes
    static let generalVoteSymbolName: String = "arrow.up.arrow.down.square"
    
    static let plainUpvoteSymbolName: String = "arrow.up"
    static let emptyUpvoteSymbolName: String = "arrow.up.square"
    static let fullUpvoteSymbolName: String = "arrow.up.square.fill"
    
    static let plainDownvoteSymbolName: String = "arrow.down"
    static let emptyDownvoteSymbolName: String = "arrow.down.square"
    static let fullDownvoteSymbolName: String = "arrow.down.square.fill"
    
    static let emptyResetVoteSymbolName: String = "minus.square"
    static let fullResetVoteSymbolName: String = "minus.square.fill"
    static let scoringOpToVoteImage: [ScoringOperation?: String] = [.upvote: "arrow.up.square.fill",
                                                                    .resetVote: "arrow.up.square",
                                                                    .downvote: "arrow.down.square.fill"]
    
    // reply/send
    static let emptyReplySymbolName: String = "arrowshape.turn.up.left"
    static let fullReplySymbolName: String = "arrowshape.turn.up.left.fill"
    static let sendSymbolName: String = "paperplane"
    static let sendSymbolNameFill: String = "paperplane.fill"
    
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
    
    // report/block
    static let reportSymbolName: String = "exclamationmark.shield"
    static let blockUserSymbolName: String = "person.fill.xmark"
    
    // post sizes
    static let postSizeSettingsSymbolName: String = "rectangle.expand.vertical"
    static let compactSymbolName: String = "rectangle.grid.1x2"
    static let compactSymbolNameFill: String = "rectangle.grid.1x2.fill"
    static let headlineSymbolName: String = "rectangle"
    static let headlineSymbolNameFill: String = "rectangle.fill"
    static let largeSymbolName: String = "text.below.photo"
    static let largeSymbolNameFill: String = "text.below.photo.fill"
    static let blurNsfwSymbolName: String = "eye.trianglebadge.exclamationmark"
    
    // feeds
    static let federatedFeedSymbolName: String = "circle.hexagongrid.circle" // "arrow.left.arrow.right.circle"
    static let federatedFeedSymbolNameFill: String = "circle.hexagongrid.circle.fill" // "arrow.left.arrow.right.circle.fill"
    static let localFeedSymbolName: String = "house.circle"
    static let localFeedSymbolNameFill: String = "house.circle.fill"
    static let subscribedFeedSymbolName: String = "newspaper.circle"
    static let subscribedFeedSymbolNameFill: String = "newspaper.circle.fill"
    static let limitImageHeightInFeedSymbolName: String = "rectangle.compress.vertical"
    
    // sort types
    static let activeSortSymbolName: String = "popcorn" // not married to this idea
    static let activeSortSymbolNameFill: String = "popcorn.fill"
    static let hotSortSymbolName: String = "flame"
    static let hotSortSymbolNameFill: String = "flame.fill"
    // we can workshop new/old--books is already used for documentation and there's an issue open saying that "new" needs a better symbol. I thought these two were funny together.
    static let newSortSymbolName: String = "hare"
    static let newSortSymbolNameFill: String = "hare.fill"
    static let oldSortSymbolName: String = "tortoise"
    static let oldSortSymbolNameFill: String = "tortoise.fill"
    static let newCommentsSymbolName: String = "exclamationmark.bubble"
    static let newCommentsSymbolNameFill: String = "exclamationmark.bubble.fill"
    static let mostCommentsSymbolName: String = "bubble.left.and.bubble.right"
    static let mostCommentsSymbolNameFill: String = "bubble.left.and.bubble.right.fill"
    static let topSymbolName: String = "trophy"
    static let topSymbolNameFill: String = "trophy.fill"
    static let timeSymbolName: String = "calendar.day.timeline.leading"
    static let timeSymbolNameFill: String = "calendar.day.timeline.leading.fill"
    
    // common operations
    static let shareSymbolName: String = "square.and.arrow.up"
    static let subscribeSymbolName: String = "plus.circle"
    static let unsubscribeSymbolName: String = "multiply.circle"
    static let blockSymbolName: String = "eye.slash"
    static let unblockSymbolName: String = "eye"
    static let filterSymbolName: String = "line.3.horizontal.decrease.circle"
    static let filterSymbolNameFill: String = "line.3.horizontal.decrease.circle.fill"
    
    // misc
    static let switchUserSymbolName: String = "person.crop.circle.badge.plus"
    static let missingSymbolName: String = "questionmark.square.dashed"
    static let connectionSymbolName: String = "antenna.radiowaves.left.and.right"
    static let hapticSymbolName: String = "hand.tap"
    static let transparencySymbolName: String = "square.on.square.intersection.dashed"
    static let presentSymbolName: String = "circle.fill"
    static let absentSymbolName: String = "circle"
    
    // MARK: - Other

    static let pictureEmoji: [String] = ["🎆", "🎇", "🌠", "🌅", "🌆", "🌁", "🌃", "🌄", "🌉", "🌌", "🌇", "🖼️", "🎑", "🏞️", "🗾", "🏙️"]
    static let infiniteLoadThresholdOffset: Int = -10
    
    // MARK: - Text

    static let blockUserPrompt: String = "Really block this user?"
    static let reportPostPrompt: String = "Really report this post?"
}
