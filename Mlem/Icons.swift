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
    static let votes: String = "arrow.up.arrow.down.square"
    static let upvote: String = "arrow.up"
    static let upvoteSquare: String = "arrow.up.square"
    static let upvoteSquareFill: String = "arrow.up.square.fill"
    static let downvote: String = "arrow.down"
    static let downvoteSquare: String = "arrow.down.square"
    static let downvoteSquareFill: String = "arrow.down.square.fill"
    static let resetVoteSquare: String = "minus.square"
    static let resetVoteSquareFill: String = "minus.square.fill"
    
    // reply/send
    static let reply: String = "arrowshape.turn.up.left"
    static let replyFill: String = "arrowshape.turn.up.left.fill"
    static let send: String = "paperplane"
    static let sendFill: String = "paperplane.fill"
    
    // save
    static let save: String = "bookmark"
    static let saveFill: String = "bookmark.fill"
    static let unsave: String = "bookmark.slash"
    static let unsaveFill: String = "bookmark.slash.fill"
    
    // mark read
    static let markRead: String = "envelope.open"
    static let markReadFill: String = "envelope.open.fill"
    static let markUnread: String = "envelope"
    static let markUnreadFill: String = "envelope.fill"
    
    // moderation
    static let moderation: String = "shield"
    static let moderationFill: String = "shield.fill"
    static let moderationReport: String = "exclamationmark.shield"
    
    // misc post
    static let posts: String = "doc.plaintext"
    static let replies: String = "bubble.right"
    static let textPost: String = "text.book.closed"
    static let titleOnlyPost: String = "character.bubble"
    static let pinned: String = "pin.fill"
    static let websiteIcon: String = "globe"
    static let hideRead: String = "book"
    
    // post sizes
    static let postSizeSetting: String = "rectangle.expand.vertical"
    static let compactPost: String = "rectangle.grid.1x2"
    static let compactPostFill: String = "rectangle.grid.1x2.fill"
    static let headlinePost: String = "rectangle"
    static let headlinePostFill: String = "rectangle.fill"
    static let largePost: String = "text.below.photo"
    static let largePostFill: String = "text.below.photo.fill"
    
    // feeds
    static let federatedFeed: String = "circle.hexagongrid"
    static let federatedFeedFill: String = "circle.hexagongrid.fill"
    static let federatedFeedCircle: String = "circle.hexagongrid.circle.fill"
    static let localFeed: String = "house"
    static let localFeedFill: String = "house.fill"
    static let localFeedCircle: String = "house.circle.fill"
    static let subscribedFeed: String = "newspaper"
    static let subscribedFeedFill: String = "newspaper.fill"
    static let subscribedFeedCircle: String = "newspaper.circle.fill"
    static let savedFeed: String = "bookmark"
    static let savedFeedFill: String = "bookmark.fill"
    static let savedFeedCircle: String = "bookmark.circle.fill"
    
    // sort types
    static let activeSort: String = "popcorn"
    static let activeSortFill: String = "popcorn.fill"
    static let hotSort: String = "flame"
    static let hotSortFill: String = "flame.fill"
    static let scaledSort: String = "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
    static let scaledSortFill: String = "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
    static let newSort: String = "hare"
    static let newSortFill: String = "hare.fill"
    static let oldSort: String = "tortoise"
    static let oldSortFill: String = "tortoise.fill"
    static let newCommentsSort: String = "exclamationmark.bubble"
    static let newCommentsSortFill: String = "exclamationmark.bubble.fill"
    static let mostCommentsSort: String = "bubble.left.and.bubble.right"
    static let mostCommentsSortFill: String = "bubble.left.and.bubble.right.fill"
    static let controversialSort: String = "bolt"
    static let controversialSortFill: String = "bolt.fill"
    static let topSortMenu: String = "text.line.first.and.arrowtriangle.forward"
    static let topSort: String = "trophy"
    static let topSortFill: String = "trophy.fill"
    static let timeSort: String = "calendar.day.timeline.leading"
    static let timeSortFill: String = "calendar.day.timeline.leading"
    
    // user flairs
    static let developerFlair: String = "hammer.fill"
    static let adminFlair: String = "crown.fill"
    static let botFlair: String = "terminal.fill"
    static let opFlair: String = "person.fill"
    static let bannedFlair: String = "multiply.circle"
    
    // entities/general Lemmy concepts
    static let instance: String = "server.rack"
    static let user: String = "person.crop.circle"
    static let userFill: String = "person.crop.circle.fill"
    static let userBlock: String = "person.fill.xmark"
    static let community: String = "building.2.crop.circle"
    static let communityFill: String = "building.2.crop.circle.fill"
    
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
    static let present: String = "circle.fill" // that's present as in "here," not as in "gift"
    static let absent: String = "circle"
    static let warning: String = "exclamationmark.triangle"
    static let hide: String = "eye.slash"
    static let show: String = "eye"
    static let blurNsfw: String = "eye.trianglebadge.exclamationmark"
    static let noContent: String = "binoculars"
    static let noPosts: String = "text.bubble"
    static let time: String = "clock"
    static let updated: String = "clock.arrow.2.circlepath"
    static let favorite: String = "star"
    static let favoriteFill: String = "star.fill"
    static let personFill: String = "person.fill"
    static let close: String = "multiply"
    static let cakeDay: String = "birthday.cake"
    
    // end of feed
    static let endOfFeedHobbit: String = "figure.climbing"
    static let endOfFeedCartoon: String = "figure.wave"
    
    // common operations
    static let share: String = "square.and.arrow.up"
    static let subscribe: String = "plus.circle"
    static let subscribed: String = "checkmark.circle"
    static let subscribePerson: String = "person.crop.circle.badge.plus"
    static let subscribePersonFill: String = "person.crop.circle.badge.plus.fill"
    static let unsubscribe: String = "multiply.circle"
    static let unsubscribePerson: String = "person.crop.circle.badge.xmark"
    static let unsubscribePersonFill: String = "person.crop.circle.badge.xmark.fill"
    static let filter: String = "line.3.horizontal.decrease.circle"
    static let filterFill: String = "line.3.horizontal.decrease.circle.fill"
    static let menu: String = "ellipsis"
    static let menuCircle: String = "ellipsis.circle"
    static let `import`: String = "square.and.arrow.down"
    static let attachment: String = "paperclip"
    static let edit: String = "pencil"
    static let delete: String = "trash"
    static let copy: String = "doc.on.doc"
    
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
    static let limitImageHeightSetting: String = "rectangle.compress.vertical"
    static let swipeUpGestureSetting: String = "arrow.up.to.line.alt"
    
    // misc
    static let switchUser: String = "person.crop.circle.badge.plus"
    static let missing: String = "questionmark.square.dashed"
    static let connection: String = "antenna.radiowaves.left.and.right"
    static let haptics: String = "hand.tap"
    static let transparency: String = "square.on.square.intersection.dashed"
    static let icon: String = "fleuron"
    static let banner: String = "flag"
    static let noWifi: String = "wifi.slash"
    static let easterEgg: String = "gift.fill"
    static let jumpButton: String = "chevron.down"
    static let jumpButtonCircle: String = "chevron.down.circle"
    static let browser: String = "safari"
    static let emptySquare: String = "square"
    static let dropdown: String = "chevron.down"
    static let noFile: String = "questionmark.folder"
    static let forward: String = "chevron.right"
    static let imageDetails: String = "doc.badge.ellipsis"
}
