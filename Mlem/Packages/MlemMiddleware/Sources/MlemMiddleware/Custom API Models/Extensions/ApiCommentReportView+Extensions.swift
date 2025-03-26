//
//  ApiCommentReport+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-16.
//

import Foundation

extension ApiCommentReportView: ReportApiBacker {
    public var cacheId: Int {
        var hasher = Hasher()
        hasher.combine(ReportType.comment)
        hasher.combine(commentReport.id)
        return hasher.finalize()
    }
    
    public var id: Int { commentReport.id }
    public var reason: String { commentReport.reason }
    public var resolved: Bool { commentReport.resolved }
    public var published: Date { commentReport.published }
    public var updated: Date? { commentReport.updated }
    
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
            bannedFromCommunity: nil // Can we assume this to be false? Can admins be banned from a local community?
        )
    }
    
    @MainActor
    func createTarget(api: ApiClient, myPersonId: Int) -> ReportTarget {
        if let commentView = toCommentView() {
            return .comment(api.caches.comment2.getModel(api: api, from: commentView))
        }
        return .legacyComment(
            api.caches.comment1.getModel(api: api, from: comment),
            community: api.caches.community1.getModel(api: api, from: community),
            creator: api.caches.person1.getModel(api: api, from: commentCreator)
        )
    }
}
