//
//  Icon.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-13.
//

import Foundation
import SwiftUI

/// SFSymbol names for icons
struct Icons {
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
    
    // misc post
    static let replies: String = "bubble.right"
    static let textPost: String = "text.book.closed"
    static let titleOnlyPost: String = "character.bubble"
    static let pinned: String = "pin.fill"
    static let websiteIcon: String = "globe"
    
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
    static let federatedFeedSymbolName: String = "circle.hexagongrid.circle"
    static let federatedFeedSymbolNameFill: String = "circle.hexagongrid.circle.fill"
    static let localFeedSymbolName: String = "house.circle"
    static let localFeedSymbolNameFill: String = "house.circle.fill"
    static let subscribedFeedSymbolName: String = "newspaper.circle"
    static let subscribedFeedSymbolNameFill: String = "newspaper.circle.fill"
    static let limitImageHeightInFeedSymbolName: String = "rectangle.compress.vertical"
    
    // sort types
    static let activeSortSymbolName: String = "popcorn"
    static let activeSortSymbolNameFill: String = "popcorn.fill"
    static let hotSortSymbolName: String = "flame"
    static let hotSortSymbolNameFill: String = "flame.fill"
    static let newSortSymbolName: String = "hare"
    static let newSortSymbolNameFill: String = "hare.fill"
    static let oldSortSymbolName: String = "tortoise"
    static let oldSortSymbolNameFill: String = "tortoise.fill"
    static let newCommentsSymbolName: String = "exclamationmark.bubble"
    static let newCommentsSymbolNameFill: String = "exclamationmark.bubble.fill"
    static let mostCommentsSymbolName: String = "bubble.left.and.bubble.right"
    static let mostCommentsSymbolNameFill: String = "bubble.left.and.bubble.right.fill"
    static let topMenu: String = "text.line.first.and.arrowtriangle.forward"
    static let topSymbolName: String = "trophy"
    static let topSymbolNameFill: String = "trophy.fill"
    static let timeSymbolName: String = "calendar.day.timeline.leading"
    static let timeSymbolNameFill: String = "calendar.day.timeline.leading.fill"
    
    // user flairs
    static let developerFlair: String = "hammer.fill"
    static let adminFlair: String = "crown.fill"
    static let botFlair: String = "terminal.fill"
    static let opFlair: String = "person.fill"
    
    // entities/general Lemmy concepts
    static let moderation: String = "shield"
    static let moderationFill: String = "shield.fill"
    static let instance: String = "server.rack"
    static let user: String = "person.circle"
    static let userFill: String = "person.circle.fill"
    
    // tabs
    static let feeds: String = "scroll"
    static let feedsFill: String = "scroll.fill"
    static let inbox: String = "mail.stack"
    static let inboxFill: String = "mail.stack.fill"
    static let search: String = "magnifyingglass"
    static let searchActive: String = "text.magnifyingglass"
    static let settings: String = "gear"
    
    // information/status
    static let success: String = "checkmark"
    static let successCircle: String = "checkmark.circle"
    static let successSquareFill: String = "checkmark.square.fill"
    static let failure: String = "xmark"
    static let warning: String = "exclamationmark.triangle"
    static let nsfw: String = "eye.slash"
    static let endOfFeed: String = "figure.climbing"
    static let noContent: String = "binoculars"
    static let noPosts: String = "text.bubble"
    static let time: String = "clock"
    static let favorite: String = "star"
    static let favoriteFill: String = "star.fill"
    
    // common operations
    static let shareSymbolName: String = "square.and.arrow.up"
    static let subscribeSymbolName: String = "plus.circle"
    static let unsubscribeSymbolName: String = "multiply.circle"
    static let blockSymbolName: String = "eye.slash"
    static let unblockSymbolName: String = "eye"
    static let filterSymbolName: String = "line.3.horizontal.decrease.circle"
    static let filterSymbolNameFill: String = "line.3.horizontal.decrease.circle.fill"
    static let menuSymbolName: String = "ellipsis"
    static let importSymbol: String = "square.and.arrow.down"
    
    // settings
    static let upvoteOnSave: String = "arrow.up.heart"
    static let readIndicatorSetting: String = "book"
    static let readIndicatorBarSetting: String = "rectangle.leftthird.inset.filled"
    static let profileTabSettings: String = "person.text.rectangle"
    static let nicknameField: String = "rectangle.and.pencil.and.ellipsis"
    static let label: String = "tag"
    static let unreadBadge: String = "envelope.badge"
    static let showAvatar: String = "person.fill.questionmark"
    static let widgetWizard: String = "wand.and.stars"
    static let thumbnail: String = "photo"
    static let author: String = "signature"
    static let websiteAddress: String = "link"
    static let leftRight: String = "arrow.left.arrow.right"
    static let developerMode: String = "wrench.adjustable.fill"
    
    // misc
    static let switchUserSymbolName: String = "person.crop.circle.badge.plus"
    static let missingSymbolName: String = "questionmark.square.dashed"
    static let connectionSymbolName: String = "antenna.radiowaves.left.and.right"
    static let hapticSymbolName: String = "hand.tap"
    static let transparencySymbolName: String = "square.on.square.intersection.dashed"
    static let presentSymbolName: String = "circle.fill"
    static let absentSymbolName: String = "circle"
    static let iconSymbolName: String = "fleuron"
    static let bannerSymbolName: String = "flag"
    static let communitySymbolName: String = "building.2.crop.circle"
    static let noWifi: String = "wifi.slash"
    static let easterEgg: String = "gift.fill"
    static let jumpButton: String = "chevron.down.circle"
    static let browser: String = "safari"
    static let emptySquare: String = "square"
    static let dropdown: String = "chevron.down"
    static let noFile: String = "questionmark.folder"
    static let delete: String = "trash"
    static let forward: String = "chevron.right"
}
