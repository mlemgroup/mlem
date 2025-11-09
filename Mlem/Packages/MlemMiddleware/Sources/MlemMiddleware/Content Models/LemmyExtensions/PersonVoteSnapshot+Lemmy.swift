//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-09-18.
//

import Foundation

extension PersonVoteSnapshot {
    init(from vote: LemmyVoteView) throws(ApiClientError) {
        let score: Int?
        if let isUpvote = vote.isUpvote {
            score = isUpvote ? 1 : -1
        } else {
            score = vote.score
        }

        guard let score else {
            throw .responseMissingRequiredData("LemmyVoteView score")
        }

        try self.init(
            creator: .init(from: vote.creator),
            score: score,
            creatorBannedFromCommunity: vote.creatorBannedFromCommunity
        )
    }
}
