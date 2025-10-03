//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-09-18.
//

import Foundation

extension PersonVoteSnapshot {
    init(from vote: LemmyVoteView) throws(ApiClientError) {
        try self.init(
            creator: .init(from: vote.creator),
            score: vote.score,
            creatorBannedFromCommunity: vote.creatorBannedFromCommunity
        )
    }
}
