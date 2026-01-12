//
//  Comment2.swift
//
//
//  Created by Sjmarf on 24/06/2024.
//

import Foundation
import Observation

@Observable
public final class Comment2: Comment2Providing {
    public static let tierNumber: Int = 2
    public var api: ApiClient
    public var comment2: Comment2 { self }
    
    public let comment1: Comment1
    
    public let creator: Person1
    public let post: Post
    public let community: Community1
    
    public var creatorIsModerator: Bool
    public var creatorIsAdmin: Bool
    public var commentCount: Int

    public var votes: VotesModel
    public var saved: Bool
    
    public var creatorBannedFromCommunity: Bool {
        guard let state = creator.isBannedFromCommunity(community) else {
            assertionFailure("Ban status should be present at this point")
            return false
        }
        return state
    }
    
    init(
        api: ApiClient,
        comment1: Comment1,
        creator: Person1,
        post: Post,
        community: Community1,
        votes: VotesModel,
        saved: Bool,
        creatorIsModerator: Bool,
        creatorIsAdmin: Bool,
        creatorBannedFromCommunity: Bool,
        commentCount: Int
    ) {
        self.api = api
        self.comment1 = comment1
        self.creator = creator
        self.post = post
        self.community = community
        self.votes = votes
        self.saved = saved
        self.creatorIsModerator = creatorIsModerator
        self.creatorIsAdmin = creatorIsAdmin
        self.commentCount = commentCount
        creator.updateKnownCommunityBanState(id: community.id, banned: creatorBannedFromCommunity)
        
        Task {
            await updateQueue.setParent(self)
        }
    }
}
