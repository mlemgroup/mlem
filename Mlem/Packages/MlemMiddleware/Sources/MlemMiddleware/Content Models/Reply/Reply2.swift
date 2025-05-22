//
//  Reply2.swift
//
//
//  Created by Sjmarf on 04/07/2024.
//

import Foundation
import Observation

@Observable
public final class Reply2: Reply2Providing, FeedLoadable {
    public typealias FilterType = InboxItemFilterType
    
    public func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort {
        switch sortType {
        case .new:
            return .new(created)
        }
    }
    
    public static let tierNumber: Int = 2
    public var api: ApiClient
    public var reply2: Reply2 { self }
    
    public let reply1: Reply1
    public let comment: Comment1
    public let creator: Person1
    public let post: Post1
    public let community: Community1
    public let recipient: Person1
    public var subscribed: Bool
    public var commentCount: Int
    public var creatorIsModerator: Bool?
    public var creatorIsAdmin: Bool
    
    public var creatorBannedFromCommunity: Bool {
        guard let state = creator.isBannedFromCommunity(community) else {
            assertionFailure("Ban status should be present at this point")
            return false
        }
        return state
    }
    
    var votesManager: StateManager<VotesModel>
    public var votes: VotesModel { votesManager.displayedValue }
    
    var savedManager: StateManager<Bool>
    public var saved: Bool { savedManager.displayedValue }
    
    init(
        api: ApiClient,
        reply1: Reply1,
        comment: Comment1,
        creator: Person1,
        post: Post1,
        community: Community1,
        recipient: Person1,
        subscribed: Bool,
        commentCount: Int,
        creatorIsModerator: Bool?,
        creatorIsAdmin: Bool,
        bannedFromCommunity: Bool,
        votesManager: StateManager<VotesModel>,
        savedManager: StateManager<Bool>
    ) {
        self.api = api
        self.reply1 = reply1
        self.comment = comment
        self.creator = creator
        self.post = post
        self.community = community
        self.recipient = recipient
        self.subscribed = subscribed
        self.commentCount = commentCount
        self.creatorIsModerator = creatorIsModerator
        self.creatorIsAdmin = creatorIsAdmin
        self.votesManager = votesManager
        self.savedManager = savedManager
        creator.updateKnownCommunityBanState(id: community.id, banned: bannedFromCommunity)
    }
}
