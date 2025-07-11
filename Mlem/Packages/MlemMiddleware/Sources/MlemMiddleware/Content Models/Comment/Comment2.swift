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
    public let post: Post1
    public let community: Community1
    
    public var creatorIsModerator: Bool
    public var creatorIsAdmin: Bool
    public var commentCount: Int
    
    var votesManager: StateManager<VotesModel>
    public var votes: VotesModel { votesManager.displayedValue }
    
    var savedManager: StateManager<Bool>
    public var saved: Bool { savedManager.displayedValue }
    
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
        post: Post1,
        community: Community1,
        votesManager: StateManager<VotesModel>,
        savedManager: StateManager<Bool>,
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
        self.votesManager = votesManager
        self.savedManager = savedManager
        self.creatorIsModerator = creatorIsModerator
        self.creatorIsAdmin = creatorIsAdmin
        self.commentCount = commentCount
        creator.updateKnownCommunityBanState(id: community.id, banned: creatorBannedFromCommunity)
    }
}
