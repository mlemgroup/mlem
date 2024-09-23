//
//  Icon.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-13.
//

import Foundation
import SwiftUI

/// SFSymbol names for icons
enum Icons {
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
    static let moderationReport: String = "flag"
    
    // inbox
    static let mention: String = "quote.bubble"
    static let message: String = "envelope"
    
    // misc post
    static let posts: String = "doc.plaintext"
    static let replies: String = "bubble.left"
    static let unreadReplies: String = "text.bubble"
    static let textPost: String = "text.book.closed"
    static let titleOnlyPost: String = "character.bubble"
    static let pin: String = "pin"
    static let pinFill: String = "pin.fill"
    static let websiteIcon: String = "globe"
    static let read: String = "book"
    static let lock: String = "lock"
    static let lockFill: String = "lock.fill"
    static let remove: String = "xmark.bin"
    static let removeFill: String = "xmark.bin.fill"
    
    // post sizes
    static let postSizeSetting: String = "rectangle.expand.vertical"
    static let compactPost: String = "rectangle.grid.1x2"
    static let compactPostFill: String = "rectangle.grid.1x2.fill"
    static let tilePost: String = "square.grid.2x2"
    static let tilePostFill: String = "square.grid.2x2.fill"
    static let headlinePost: String = "rectangle"
    static let headlinePostFill: String = "rectangle.fill"
    static let largePost: String = "text.below.photo"
    static let largePostFill: String = "text.below.photo.fill"
    
    // feeds
    static let federatedFeed: String = "circle.hexagongrid"
    static let federatedFeedFill: String = "circle.hexagongrid.fill"
    static let federatedFeedCircle: String = "circle.hexagongrid.circle.fill"
    static let instanceFeed: String = "building.2"
    static let instanceFeedFill: String = "building.2.fill"
    static let instanceFeedCircle: String = "building.2.crop.circle"
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
    static let alphabeticalSort: String = "textformat"
    static let scoreSort: String = "star"
    static let usersSort: String = "person.2"
    static let versionSort: String = "server.rack"
    
    // user flairs
    static let developerFlair: String = "hammer.fill"
    static let adminFlair: String = "crown.fill"
    static let botFlair: String = "terminal.fill"
    static let opFlair: String = "person.fill"
    static let instanceBannedFlair: String = "xmark.circle.fill"
    static let communityBannedFlair: String = "xmark.shield.fill"
    static let newAccountFlair: String = "leaf.fill"
    
    // markdown
    static let bold: String = "bold"
    static let italic: String = "italic"
    static let strikethrough: String = "strikethrough"
    static let superscript: String = "textformat.superscript"
    static let `subscript`: String = "textformat.subscript"
    // Potentially "chevron.left.chevron.right" is better, it's iOS 18+ though
    static let inlineCode: String = "chevron.left.forwardslash.chevron.right"
    static let quote: String = "quote.opening"
    static let heading: String = "textformat.size"
    static let uploadImage: String = "photo"
    static let spoiler: String = "eye"
    
    // entities/general Lemmy concepts
    static let federation: String = "point.3.filled.connected.trianglepath.dotted"
    static let instance: String = "building.2"
    static let instanceFill: String = "building.2.fill"
    static let instanceCircle: String = "building.2.crop.circle"
    static let instanceCircleFill: String = "building.2.crop.circle.fill"
    static let person: String = "person"
    static let personFill: String = "person.fill"
    static let personCircle: String = "person.crop.circle"
    static let personCircleFill: String = "person.crop.circle.fill"
    static let community: String = "house"
    static let communityFill: String = "house.fill"
    static let communityCircle: String = "house.circle"
    static let communityCircleFill: String = "house.circle.fill"
    
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
    static let successCircleFill: String = "checkmark.circle.fill"
    static let successSquareFill: String = "checkmark.square.fill"
    static let failure: String = "xmark"
    static let failureCircle: String = "xmark.circle"
    static let failureCircleFill: String = "xmark.circle.fill"
    static let present: String = "circle.fill" // that's present as in "here," not as in "gift"
    static let absent: String = "circle"
    static let warning: String = "exclamationmark.triangle"
    static let warningFill: String = "exclamationmark.triangle.fill"
    static let hide: String = "eye.slash"
    static let hideFill: String = "eye.slash.fill"
    static let block: String = "hand.raised"
    static let blockFill: String = "hand.raised.fill"
    static let unblock: String = "hand.raised.slash"
    static let unblockFill: String = "hand.raised.slash.fill"
    static let nsfwTag: String = "nsfw"
    static let show: String = "eye"
    static let showFill: String = "eye.fill"
    static let blurNsfw: String = "eye.trianglebadge.exclamationmark"
    static let noContent: String = "binoculars"
    static let noPosts: String = "text.bubble"
    static let time: String = "clock"
    static let updated: String = "clock.arrow.2.circlepath"
    static let favorite: String = "star"
    static let favoriteFill: String = "star.fill"
    static let unfavorite: String = "star.slash"
    static let unfavoriteFill: String = "star.slash.fill"
    static let close: String = "multiply"
    static let closeCircle: String = "xmark.circle"
    static let closeCircleFill: String = "xmark.circle.fill"
    static let cakeDay: String = "birthday.cake"
    static let cakeDayFill: String = "birthday.cake.fill"
    static let undoCircleFill: String = "arrow.uturn.backward.circle.fill"
    static let errorCircleFill: String = "exclamationmark.circle.fill"
    static let proxy: String = "firewall"
    
    // uptime
    static let uptimeOffline: String = "xmark.circle.fill"
    static let uptimeOnline: String = "checkmark.circle.fill"
    static let uptimeOutage: String = "exclamationmark.circle.fill"
    
    // end of feed
    static let endOfFeedHobbit: String = "figure.climbing"
    static let endOfFeedCartoon: String = "figure.wave"
    static let endOfFeedTurtle: String = "tortoise"
    
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
    static let menuCircleFill: String = "ellipsis.circle.fill"
    static let `import`: String = "square.and.arrow.down"
    static let attachment: String = "paperclip"
    static let edit: String = "pencil"
    static let delete: String = "trash"
    static let deleteFill: String = "trash.fill"
    static let undelete: String = "arrow.up.trash"
    static let copy: String = "doc.on.doc"
    static let copyFill: String = "doc.on.doc.fill"
    static let paste: String = "doc.on.clipboard"
    static let signOut: String = "minus.circle"
    static let collapseComment: String = "arrow.down.and.line.horizontal.and.arrow.up"
    static let expandComment: String = "arrow.up.and.line.horizontal.and.arrow.down"
    static let refresh: String = "arrow.clockwise"
    static let select: String = "selection.pin.in.out"
    
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
    static let appLockSettings: String = "lock.app.dashed"
    static let collapseComments: String = "arrow.down.and.line.horizontal.and.arrow.up"
    static let ban: String = "xmark.circle"
    static let logIn: String = "person.text.rectangle"
    static let signUp: String = "pencil.and.list.clipboard"
    
    // misc
    static let `private`: String = "lock"
    static let email: String = "envelope"
    static let photo: String = "photo"
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
    static let dropDown: String = "chevron.down"
    static let dropDownCircleFill: String = "chevron.down.circle.fill"
    static let noFile: String = "questionmark.folder"
    static let forward: String = "chevron.right"
    static let imageDetails: String = "doc.badge.ellipsis"
    static let accountSwitchReload: String = "arrow.2.circlepath"
    static let accountSwitchKeepPlace: String = "checkmark.diamond"
}
