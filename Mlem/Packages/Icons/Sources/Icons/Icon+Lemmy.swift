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
        
        public let scoreCounter: Icon = .applyFill("arrow.up.arrow.down.circle")
        public let upvoteCounter: Icon = .applyFill("arrow.up.circle")
        public let downvoteCounter: Icon = .applyFill("arrow.down.circle")
        
        // MARK: - Reply/Send
        
        public let reply: Icon = .applyFill("arrowshape.turn.up.left")
        public let replyCounter: Icon = .applyFill("arrowshape.turn.up.left.circle")
        
        public let send: Icon = .applyFill("paperplane")
        public let sendMessage: Icon = .baseOnly("arrow.up.circle.fill")
        
        // MARK: - Save
        
        @inlinable var saved: Icon { addSave }
        public let addSave: Icon = .applyFill("bookmark")
        public let removeSave: Icon = .applyFill("bookmark.slash")
        
        // MARK: - Mark Read
        
        public let markRead: Icon = .applyFill("envelope.open")
        public let markUnread: Icon = .applyFill("envelope")
        
        // MARK: - Block
        
        public let block: Icon = .applyFill("hand.raised")
        public let unblock: Icon = .applyFill("hand.raised.slash")
        
        // MARK: - Pin
        
        @inlinable public var pinned: Icon { addPin }
        public let addPin: Icon = .applyFill("pin")
        public let removePin: Icon = .applyFill("pin.slash")
        
        // MARK: - Lock
        
        @inlinable public var locked: Icon { addLock }
        public let addLock: Icon = .applyFill("lock")
        public let removeLock: Icon = .applyFill("lock.open")
        
        // MARK: - Remove
        
        @inlinable public var removed: Icon { remove }
        public let remove: Icon = .applyFill("xmark.bin")
        public let restore: Icon = .applyFill("arrow.up.bin")
        
        // MARK: - Purge
        
        @inlinable public var purged: Icon { purge }
        public let purge: Icon = .baseOnly("burn")
        
        // MARK: - Subscribe

        @inlinable public var subscribed: Icon { subscribe }
        public let subscribe: Icon = .applyFill("plus.circle")
        public let unsubscribe: Icon = .applyFill("multiply.circle")
        
        // MARK: - Subscribe

        @inlinable public var favorited: Icon { favorite }
        public let favorite: Icon = .applyFill("star")
        public let unfavorite: Icon = .applyFill("star.slash")
        
        // MARK: - Collapse

        public let collapse: Icon = .baseOnly("arrow.down.and.line.horizontal.and.arrow.up")
        public let expand: Icon = .baseOnly("arrow.up.and.line.horizontal.and.arrow.down")

        // MARK: - Moderation
        
        public let moderation: Icon = .applyFill("shield")
        public let administration: Icon = .applyFill("crown")
        
        @inlinable public var addModerator: Icon { moderation }
        public let removeModerator: Icon = .applyFill("shield.slash")
        
        public let report: Icon = .applyFill("flag")
        public let registrationApplication: Icon = .applyFill("list.clipboard")
        public let modlog: Icon = .applyFill("book.pages")
        public let transferCommunity: Icon = .baseOnly("arrow.right")
        
        @inlinable public var addAdministrator: Icon { administration }
        public let removeAdministrator: Icon = .applyFill("arrowshape.down")
        
        // MARK: - Inbox
        
        public let mention: Icon = .applyFill("quote.bubble")
        public let message: Icon = .applyFill("envelope")
        
        // MARK: - Misc Post
        
        public let post: Icon = .applyFill("doc.plaintext")
        public let comment: Icon = .applyFill("bubble.left")
        
        @inlinable public var replies: Icon { comment }
        public let unreadReplies: Icon = .applyFill("text.bubble")
        
        public let textPost: Icon = .applyFill("text.book.closed")
        public let titleOnlyPost: Icon = .applyFill("character.bubble")
        
        // MARK: - Feeds

        public let feed: Icon = .applyFill("scroll")
        public let federatedFeed: Icon = .applyFill("circle.hexagongrid")
        public let localFeed: Icon = .applyFill("building.2")
        public let subscribedFeed: Icon = .applyFill("newspaper")
        @inlinable public var savedFeed: Icon { saved }
        
        // MARK: - Sort Types

        public let activeSort: Icon = .applyFill("popcorn")
        public let hotSort: Icon = .applyFill("flame")
        public let scaledSort: Icon = .baseOnly("arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
        public let newSort: Icon = .applyFill("hare")
        public let oldSort: Icon = .applyFill("tortoise")
        public let newCommentsSort: Icon = .applyFill("exclamationmark.bubble")
        public let mostCommentsSort: Icon = .applyFill("bubble.left.and.bubble.right")
        public let controversialSort: Icon = .applyFill("bolt")
        public let topSort: Icon = .applyFill("trophy")
        public let alphabeticalSort: Icon = .baseOnly("textformat")
        public let scoreSort: Icon = .applyFill("star")
        public let usersSort: Icon = .applyFill("person.2")
        public let versionSort: Icon = .applyFill("server.rack")
        
        // MARK: - Flairs

        public let developerFlair: Icon = .applyFill("hammer")
        public let botFlair: Icon = .applyFill("terminal")
        public let opFlair: Icon = .applyFill("person")
        public let instanceBannedFlair: Icon = .applyFill("xmark.square")
        public let communityBannedFlair: Icon = .applyFill("xmark.shield")
        public let mewAccountFlair: Icon = .applyFill("leaf")
        
        // MARK: - General Concepts

        public let federation: Icon = .baseOnly("point.3.filled.connected.trianglepath.dotted")
        public let instance: Icon = .applyFill("building.2")
        public let community: Icon = .applyFill("house")
        public let person: Icon = .baseOnly("person")
        public let inbox: Icon = .applyFill("mail.stack")
        
        // MARK: - Information/Status

        public let noContent: Icon = .baseOnly("binoculars")
    }
    
    static let lemmy: LemmyIcons = .init()
}
