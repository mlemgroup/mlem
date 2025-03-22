//
//  Report.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-16.
//

import Foundation

extension Report {
    public var cacheId: Int {
        var hasher = Hasher()
        hasher.combine(target.type)
        hasher.combine(id)
        return hasher.finalize()
    }
    
    @MainActor
    func update(with report: any ReportApiBacker, semaphore: UInt? = nil) {
        setIfChanged(\.updated, report.updated)
        setIfChanged(\.reason, report.reason)
        
        setIfChanged(\.resolver, api.caches.person1.getOptionalModel(api: api, from: report.resolver))
        
        creator.update(with: report.creator)
        
        resolvedManager.updateWithReceivedValue(report.resolved, semaphore: semaphore)
        
        switch target {
        case let .post(post):
            if let postView = (report as? ApiPostReportView)?.toPostView() {
                post.update(with: postView, semaphore: semaphore)
            }
        case let .comment(comment):
            if let commentView = (report as? ApiCommentReportView)?.toCommentView() {
                comment.update(with: commentView, semaphore: semaphore)
            }
        case let .message(message):
            if let messageView = (report as? ApiPrivateMessageReportView)?.toPrivateMessageView() {
                message.update(with: messageView, semaphore: semaphore)
            } else {
                assertionFailure()
            }
        case let .legacyPost(post, community, creator):
            if let report = report as? ApiPostReportView {
                post.update(with: report.post)
                community.update(with: report.community)
                creator.update(with: report.postCreator)
            } else {
                assertionFailure()
            }
        case let .legacyComment(comment, community, creator):
            if let report = report as? ApiCommentReportView {
                comment.update(with: report.comment)
                community.update(with: report.community)
                creator.update(with: report.commentCreator)
            } else {
                assertionFailure()
            }
        }
    }
}
