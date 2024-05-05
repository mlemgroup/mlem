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
    static let votes: String = "arrow.up.arrow.down"
    static let votesSquare: String = "arrow.up.arrow.down.square"
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
    static let messageReportSetting: String = "envelope.badge.shield.half.filled"
    
    // misc post
    static let posts: String = "doc.plaintext"
    static let postsFill: String = "doc.plaintext.fill"
    static let replies: String = "bubble.left"
    static let unreadReplies: String = "text.bubble"
    static let textPost: String = "text.book.closed"
    static let titleOnlyPost: String = "character.bubble"
    static let pinned: String = "pin.fill"
    static let unpinned: String = "pin.slash.fill"
    static let websiteIcon: String = "globe"
    static let read: String = "book"
    static let locked: String = "lock.fill"
    static let unlocked: String = "lock.open.fill"
    static let removed: String = "xmark.bin.fill"
    static let restored: String = "arrow.up.bin.fill"
    
    // inbox
    static let message = "envelope"
    static let messageFill = "envelope.fill"
    
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
    static let localFeed: String = "house"
    static let localFeedFill: String = "house.fill"
    static let subscribedFeed: String = "newspaper"
    static let subscribedFeedFill: String = "newspaper.fill"
    static let savedFeed: String = "bookmark"
    static let savedFeedFill: String = "bookmark.fill"
    static let moderatedFeed: String = moderation
    static let moderatedFeedFill: String = moderationFill
    
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
    static let newCommentsSort: String = "plus.bubble"
    static let newCommentsSortFill: String = "plus.bubble.fill"
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
    static let botFlair: String = "terminal.fill"
    static let opFlair: String = "person.fill"
    static let instanceBannedFlair: String = "xmark.circle.fill"
    static let communityBannedFlair: String = "xmark.shield.fill"
    
    // entities/general Lemmy concepts
    static let federation: String = "point.3.filled.connected.trianglepath.dotted"
    static let instance: String = "server.rack"
    static let user: String = "person.crop.circle"
    static let userFill: String = "person.crop.circle.fill"
    static let userBlock: String = "person.fill.xmark"
    static let community: String = "building.2.crop.circle"
    static let communityFill: String = "building.2.crop.circle.fill"
    static let communityButton: String = "building.2"
    static let admin: String = "crown"
    static let adminFill: String = "crown.fill"
    static let unAdmin: String = "cloud.bolt.fill" // idk what to do for this one
    
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
    static let unfavorite: String = "star.slash"
    static let unfavoriteFill: String = "star.slash.fill"
    static let person: String = "person"
    static let personFill: String = "person.fill"
    static let close: String = "multiply"
    static let cakeDay: String = "birthday.cake"
    
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
    static let add: String = "plus"
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
    static let copyFill: String = "doc.on.doc.fill"
    static let paste: String = "doc.on.clipboard"
    static let select: String = "selection.pin.in.out"
    static let choosePhoto: String = "photo.on.rectangle"
    static let chooseFile: String = "folder"
    
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
    
    // mod tools
    static let auditUser: String = "person.crop.circle.badge.questionmark.fill"
    static let communityBan: String = "xmark.shield"
    static let communityBanFill: String = "xmark.shield.fill"
    static let communityBanned: String = "xmark.shield.fill"
    static let communityUnban: String = "checkmark.shield"
    static let communityUnbanned: String = "checkmark.shield.fill"
    static let instanceBan: String = "xmark.circle"
    static let instanceUnban: String = "checkmark.circle"
    static let instanceBanned: String = "xmark.circle.fill"
    static let instanceUnbanned: String = "checkmark.circle.fill"
    static let unmod: String = "shield.slash"
    static let unmodFill: String = "shield.slash.fill"
    static let pin: String = "pin"
    static let unpin: String = "pin.slash"
    static let lock: String = "lock"
    static let unlock: String = "lock.open"
    static let remove: String = "xmark.bin"
    static let removeFill: String = "xmark.bin.fill"
    static let purge: String = "burn"
    static let restore: String = "arrow.up.bin"
    static let restoreFill: String = "arrow.up.bin.fill"
    static let commentReport: String = "text.bubble"
    static let commentReportFill: String = "text.bubble.fill"
    static let registrationApplication: String = "list.clipboard"
    static let registrationApplicationFill: String = "list.clipboard.fill"
    static let resolve: String = "checkmark.circle"
    static let resolveFill: String = "checkmark.circle.fill"
    static let unresolve: String = "checkmark.gobackward"
    static let approve: String = "checkmark"
    static let approveCircle: String = "checkmark.circle"
    static let approveCircleFill: String = "checkmark.circle.fill"
    static let deny: String = "xmark"
    static let denyCircle: String = "xmark.circle"
    static let denyCircleFill = "xmark.circle.fill"
    
    // fediseer
    static let fediseer: String = "shield.checkered"
    static let fediseerGuarantee: String = "checkmark.seal.fill"
    static let fediseerUnguarantee: String = "xmark.seal.fill"
    static let fediseerEndorsement: String = "signature"
    static let fediseerHesitation: String = "exclamationmark.triangle.fill"
    static let fediseerCensure: String = "exclamationmark.octagon.fill"
    
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
    static let dropdown: String = "chevron.down"
    static let noFile: String = "questionmark.folder"
    static let forward: String = "chevron.right"
    static let imageDetails: String = "doc.badge.ellipsis"
}
