//
//  Icons+StaticValues.swift
//  Icons
//
//  Created by Sjmarf on 2025-04-06.
//

import Foundation

public extension Icon {
    struct LemmyIcons {
        // MARK: - Votes
        
        @inlinable public var upvoted: Icon { addUpvote }
        @inlinable public var downvoted: Icon { addDownvote }
        
        public let addUpvote: Icon = .applySquare("arrow.up")
        public let addDownvote: Icon = .applySquare("arrow.down")
        
        public let removeUpvote: Icon = .custom { variant in
            switch variant {
            case .active: "minus.square.fill"
            case .inactive: "minus.square"
            default: "arrow.up.slash"
            }
        }
        
        public let removeDownvote: Icon = .custom { variant in
            switch variant {
            case .active: "minus.square.fill"
            case .inactive: "minus.square"
            default: "arrow.down.slash"
            }
        }
        
        public let votes: Icon = .applySquare("arrow.up.arrow.down")
        
        public let scoreCounter: Icon = .init("arrow.up.arrow.down.circle")
        public let upvoteCounter: Icon = .init("arrow.up.circle")
        public let downvoteCounter: Icon = .init("arrow.down.circle")
        
        // MARK: - Reply/Send
        
        public let reply: Icon = .init("arrowshape.turn.up.left")
        public let replyCounter: Icon = .init("arrowshape.turn.up.left.circle")
        
        public let send: Icon = .init("paperplane")
        public let sendMessage: Icon = .init("arrow.up.circle.fill")
        
        // MARK: - Save
        
        @inlinable public var saved: Icon { addSave }
        public let addSave: Icon = .init("bookmark")
        public let removeSave: Icon = .init("bookmark.slash")
        
        // MARK: - Mark Read
        
        public let markRead: Icon = .init("envelope.open")
        public let markUnread: Icon = .init("envelope")
        
        // MARK: - Block
        
        public let block: Icon = .init("hand.raised")
        public let unblock: Icon = .init("hand.raised.slash")
        
        // MARK: - Pin
        
        @inlinable public var pinned: Icon { addPin }
        public let addPin: Icon = .init("pin")
        public let removePin: Icon = .init("pin.slash")
        
        // MARK: - Lock
        
        @inlinable public var locked: Icon { addLock }
        public let addLock: Icon = .init("lock")
        public let removeLock: Icon = .init("lock.open")
        
        // MARK: - Remove
        
        @inlinable public var removed: Icon { remove }
        public let remove: Icon = .init("xmark.bin")
        public let restore: Icon = .init("arrow.up.bin")
        
        // MARK: - Purge
        
        @inlinable public var purged: Icon { purge }
        public let purge: Icon = .init("burn")
        
        // MARK: - Ban

        @inlinable public var bannedFromInstance: Icon { banFromInstance }
        public let banFromInstance: Icon = .init("xmark.square")
        public let unbanFromInstance: Icon = .init("checkmark.square")
        @inlinable public var bannedFromCommunity: Icon { banFromCommunity }
        public let banFromCommunity: Icon = .init("xmark.shield")
        public let unbanFromCommunity: Icon = .init("checkmark.shield")

        // MARK: - Subscribe

        public let subscribed: Icon = .init("checkmark.circle")
        public let subscribe: Icon = .init("plus.circle")
        public let unsubscribe: Icon = .init("multiply.circle")
        public let didUnsubscribe: Icon = .init("person.slash")
        
        // MARK: - Subscribe

        @inlinable public var favorited: Icon { favorite }
        public let favorite: Icon = .init("star")
        public let unfavorite: Icon = .init("star.slash")

        // MARK: - Moderation
        
        public let moderation: Icon = .init("shield")
        public let administration: Icon = .init("crown")
        
        @inlinable public var addModerator: Icon { moderation }
        public let removeModerator: Icon = .init("shield.slash")
        
        public let report: Icon = .init("flag")
        public let registrationApplication: Icon = .init("list.clipboard")
        public let modlog: Icon = .init("book.pages")
        public let transferCommunity: Icon = .init("arrow.right")
        
        @inlinable public var addAdministrator: Icon { administration }
        public let removeAdministrator: Icon = .init("arrowshape.down")
        
        // MARK: - Inbox
        
        public let mention: Icon = .init("quote.bubble")
        public let message: Icon = .init("envelope")
        
        // MARK: - Misc Post
        
        public let post: Icon = .init("doc.plaintext")
        public let comment: Icon = .init("bubble.left")
        public let crosspost: Icon = .init("shuffle")
        
        @inlinable public var replies: Icon { comment }
        public let unreadReplies: Icon = .init("text.bubble")
        
        public let textPost: Icon = .init("text.book.closed")
        public let titleOnlyPost: Icon = .init("character.bubble")
        
        // MARK: - Feeds

        public let feed: Icon = .init("scroll")
        public let federatedFeed: Icon = .init("circle.hexagongrid")
        public let localFeed: Icon = .init("building.2")
        public let subscribedFeed: Icon = .init("newspaper")
        @inlinable public var savedFeed: Icon { saved }
        @inlinable public var moderatedFeed: Icon { moderation }

        // MARK: - Sort Types

        public let activeSort: Icon = .init("popcorn")
        public let hotSort: Icon = .init("flame")
        public let scaledSort: Icon = .init("arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
        public let newSort: Icon = .init("hare")
        public let oldSort: Icon = .init("tortoise")
        public let newCommentsSort: Icon = .init("exclamationmark.bubble")
        public let mostCommentsSort: Icon = .init("bubble.left.and.bubble.right")
        public let controversialSort: Icon = .init("bolt")
        public let topSort: Icon = .init("trophy")
        public let alphabeticalSort: Icon = .init("textformat")
        public let scoreSort: Icon = .init("star")
        public let usersSort: Icon = .init("person.2")
        public let versionSort: Icon = .init("server.rack")
        
        // MARK: - Flairs

        public let developerFlair: Icon = .init("hammer")
        public let botFlair: Icon = .init("terminal")
        public let opFlair: Icon = .init("person")
        public let newAccountFlair: Icon = .init("leaf")
        public let cakeDay: Icon = .init("birthday.cake")
        
        // MARK: - General Concepts

        public let federation: Icon = .init("point.3.filled.connected.trianglepath.dotted")
        public let `private`: Icon = .init("lock")
        public let captcha: Icon = .init("photo")
        public let instance: Icon = .init("building.2")
        public let community: Icon = .init("house")
        public let person: Icon = .init("person")
        public let inbox: Icon = .init("mail.stack")
        public let imageProxy: Icon = .init("firewall")
        public let subscriptionList: Icon = .init("list.bullet")
        
        @inlinable public var communityAvatar: Icon { community }
        public let instanceAvatar: Icon = .init("building.2.crop.circle")
        public let personAvatar: Icon = .init("person.crop.circle")

        // MARK: - Other

        public let noContent: Icon = .init("binoculars")
        public let openAccountSwitcher: Icon = .init("person.crop.rectangle.stack.fill")
        public let switchAccount: Icon = .init("arrow.left.arrow.right")
        public let switchAccountAndReload: Icon = .init("arrow.2.circlepath")
        public let switchAccountAndKeepPlace: Icon = .init("checkmark.diamond")
        
        public let jumpButton: Icon = .init("chevron.down")
        public let jumpToLastPositionButton: Icon = .init("chevron.down.2")
        
        public let nsfwTag: Icon = .init("nsfw", source: .custom)
        
        public func notificationCount(_ count: Int) -> Icon {
            .init(count <= 50 ? "\(count).circle.fill" : "exclamationmark.circle.fill")
        }
    }
    
    static let lemmy: LemmyIcons = .init()
}
