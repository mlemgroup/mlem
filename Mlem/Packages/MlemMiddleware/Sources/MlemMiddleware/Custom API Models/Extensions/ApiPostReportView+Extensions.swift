//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-16.
//

import Foundation

extension ApiPostReportView {
    func toPostView() -> ApiPostView? {
        guard let subscribed, let saved, let read, let creatorBlocked, let unreadComments else { return nil }
        return .init(
            post: post,
            creator: postCreator,
            community: community,
            creatorBannedFromCommunity: creatorBannedFromCommunity,
            counts: counts,
            subscribed: subscribed,
            saved: saved,
            read: read,
            creatorBlocked: creatorBlocked,
            myVote: myVote,
            unreadComments: unreadComments,
            creatorIsModerator: creatorIsModerator,
            creatorIsAdmin: creatorIsAdmin,
            bannedFromCommunity: nil, // Can we assume this to be false? Can admins be banned from a local community?
            hidden: hidden,
            imageDetails: nil,
            communityActions: nil,
            personActions: nil,
            postActions: nil,
            instanceActions: nil,
            creatorCommunityActions: nil,
            canMod: nil
        )
    }
}
