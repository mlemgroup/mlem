//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-16.
//

import Foundation

extension ApiPostReportView: ReportApiBacker {
    public var cacheId: Int {
        var hasher = Hasher()
        hasher.combine(ReportType.post)
        hasher.combine(postReport.id)
        return hasher.finalize()
    }
    
    public var id: Int { postReport.id }
    var reason: String { postReport.reason }
    var resolved: Bool { postReport.resolved }
    var published: Date { postReport.published }
    var updated: Date? { postReport.updated }
    
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
            tags: nil // TODO: Store tags here!
        )
    }
    
    @MainActor
    func createTarget(api: ApiClient, myPersonId: Int) -> ReportTarget {
        if let postView = toPostView() {
            return .post(api.caches.post2.getModel(api: api, from: postView))
        }
        return .legacyPost(
            api.caches.post1.getModel(api: api, from: post),
            community: api.caches.community1.getModel(api: api, from: community),
            creator: api.caches.person1.getModel(api: api, from: postCreator)
        )
    }
}
