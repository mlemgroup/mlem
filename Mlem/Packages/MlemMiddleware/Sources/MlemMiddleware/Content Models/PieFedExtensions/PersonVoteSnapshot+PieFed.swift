//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-09-18.
//

import Foundation

extension PersonVoteSnapshot {
    init(from vote: PieFedPostLikeView) throws(ApiClientError) {
        self.creator = try .init(from: vote.creator)
        self.score = vote.score
        self.creatorBannedFromCommunity = vote.creatorBannedFromCommunity
    }
    
    init(from vote: PieFedCommentLikeView) throws(ApiClientError) {
        self.creator = try .init(from: vote.creator)
        self.score = vote.score
        self.creatorBannedFromCommunity = vote.creatorBannedFromCommunity
    }
}
