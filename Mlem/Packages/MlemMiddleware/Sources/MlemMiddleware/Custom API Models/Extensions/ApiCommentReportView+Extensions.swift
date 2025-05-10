//
//  ApiCommentReport+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-16.
//

import Foundation

extension ApiCommentReportView {
    func toCommentView() -> ApiCommentView? {
        guard let subscribed, let saved, let creatorBlocked else { return nil }
        return .init(
            comment: comment,
            creator: commentCreator,
            post: post,
            community: community,
            counts: counts,
            creatorBannedFromCommunity: creatorBannedFromCommunity,
            subscribed: subscribed,
            saved: saved,
            creatorBlocked: creatorBlocked,
            myVote: myVote,
            creatorIsModerator: creatorIsModerator,
            creatorIsAdmin: creatorIsAdmin,
            bannedFromCommunity: nil, // Can we assume this to be false? Can admins be banned from a local community?
            communityActions: nil,
            commentActions: nil,
            personActions: nil,
            instanceActions: nil,
            creatorCommunityActions: nil,
            canMod: nil
        )
    }
}
