//
//  PersonVote.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-18.
//

import Foundation
import Observation

@Observable
public class PersonVote: ContentModel {
    public static var tierNumber: Int = 1
    
    public enum Target: Hashable {
        case post(id: Int)
        case comment(id: Int)
    }
    
    public let api: ApiClient

    public let target: Target
    public let communityId: Int
    
    public let creator: Person1
    public var vote: ScoringOperation
    
    public var bannedFromCommunity: Bool {
        guard let state = creator.isBannedFromCommunity(id: communityId) else {
            assertionFailure("Ban status should be present at this point")
            return false
        }
        return state
    }
    init(
        api: ApiClient,
        target: Target,
        communityId: Int,
        creator: Person1,
        vote: ScoringOperation,
        creatorBannedFromCommunity: Bool?
    ) {
        self.api = api
        self.target = target
        self.communityId = communityId
        self.creator = creator
        self.vote = vote
        if let creatorBannedFromCommunity {
            creator.updateKnownCommunityBanState(id: communityId, banned: creatorBannedFromCommunity)
        }
    }
}
