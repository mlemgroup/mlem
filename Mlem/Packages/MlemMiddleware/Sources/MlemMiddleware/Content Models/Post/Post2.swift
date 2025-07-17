//
//  Post2.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation
import Observation

@Observable
public final class Post2: Post2Providing {
    public static let tierNumber: Int = 2
    public var api: ApiClient
    public var post2: Post2 { self }
    
    public let post1: Post1
    
    public let creator: Person1
    public let community: Community1
    
    public var creatorIsModerator: Bool
    public var creatorIsAdmin: Bool
    public var commentCount: Int
    public var unreadCommentCount: Int
    
    public var votes: VotesModel
    
    public var read: Bool { readQueued || readStatus }
    internal var readStatus: Bool // indicates server-side read status; can be state faked
    internal var readQueued: Bool = false // indicates post is queued to be marked read, but not submitted
    
    public var saved: Bool
    
    public var hidden: Bool
    
    public var creatorBannedFromCommunity: Bool {
        guard let state = creator.isBannedFromCommunity(community) else {
            assertionFailure("Ban status should be present at this point")
            return false
        }
        return state
    }
    
    init(
        api: ApiClient,
        post1: Post1,
        creator: Person1,
        community: Community1,
        votes: VotesModel,
        creatorIsModerator: Bool,
        creatorIsAdmin: Bool,
        creatorBannedFromCommunity: Bool,
        commentCount: Int,
        unreadCommentCount: Int,
        saved: Bool,
        read: Bool,
        hidden: Bool
    ) {
        self.api = api
        self.post1 = post1
        self.creator = creator
        self.community = community
        self.votes = votes
        self.creatorIsModerator = creatorIsModerator
        self.creatorIsAdmin = creatorIsAdmin
        self.commentCount = commentCount
        self.unreadCommentCount = unreadCommentCount
        self.saved = saved
        self.readStatus = read
        self.hidden = hidden
        creator.updateKnownCommunityBanState(id: community.id, banned: creatorBannedFromCommunity)
        
        Task {
            await updateQueue.setParent(self)
        }
    }
    
    deinit {
        let post1 = self.post1
        Task {
            await post1.updateQueue.setParent(post1)
        }
    }
}
